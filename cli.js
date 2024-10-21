#!/usr/bin/env node
// @ts-nocheck

const fs = require("fs");
const strapi = require("@strapi/strapi"); // eslint-disable-line

const getStrapiApp = async () => {
  process.env.CONFIG_SYNC_CLI = true;

  try {
    const tsUtils = require("@strapi/typescript-utils"); // eslint-disable-line

    const appDir = process.cwd();
    const isTSProject = await tsUtils.isUsingTypeScript(appDir);
    const outDir = await tsUtils.resolveOutDir(appDir);
    const alreadyCompiled = await fs.existsSync(outDir);

    if (isTSProject && !alreadyCompiled) {
      await tsUtils.compile(appDir, {
        watch: false,
        configOptions: { options: { incremental: true } },
      });
    }

    const distDir = isTSProject ? outDir : appDir;

    const app = await strapi({ appDir, distDir }).load();

    return app;
  } catch (e) {
    // Fallback for pre Strapi 4.2.
    const app = await strapi().load();
    return app;
  }
};

const generateApiToken = async () => {
  const app = await getStrapiApp();

  // const apiToken = await app.service('admin::api-token').create(attributes);
  // const apiToken = await app.service("admin::api-token").get();
  // const tokenId = (await service.getByName("test")).id;
  // const token = await service.regenerate(tokenId)
  const service = await app.service("admin::api-token");
  const tokenName = "test3";
  let tokenAttrs = await service.getByName(tokenName);
  if (!!!tokenAttrs) {
    const attributes = {
      name: tokenName,
      description: tokenName,
      type: "read-only",
      lifespan: null,
    };
    tokenAttrs = await app.service("admin::api-token").create(attributes);
  } else {
    const tokenId = tokenAttrs.id;
    tokenAttrs = await service.regenerate(tokenId);
  }
  console.log(tokenAttrs.accessKey);
  process.exit(0);
};

generateApiToken();
