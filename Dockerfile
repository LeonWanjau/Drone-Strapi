FROM node:18.20-alpine AS BASE
RUN apk add --no-cache python3 py3-pip

FROM base AS strapi_deps
WORKDIR /app
COPY ./package.json ./package-lock.json* ./
RUN npm ci

FROM base AS strapi_builder
WORKDIR /app
COPY --from=strapi_deps /app/node_modules ./node_modules
COPY ./ ./
RUN NODE_ENV=production npm run build

FROM base as runner
WORKDIR /app
COPY --from=strapi_builder /app ./
ARG DB_FILE_PATH=.tmp/data.db
ARG STRAPI_EMAIL=admin@mail.com
ARG STRAPI_PASSWORD=12345678aA
ARG STRAPI_PORT=1337
# Create volume
VOLUME [ "./.tmp" ]
# If db file doesn't exist import data and create a new token
RUN if [ ! -f $DB_FILE_PATH ]; then npm run strapi import -- -f export.tar.gz --force; node cli.js;  fi
# Create user in case they don't exist
RUN npm run strapi admin:create-user -- --firstname=Admin --lastname=User --email=${STRAPI_EMAIL} --password=${STRAPI_PASSWORD}
# If user exists, set their password to the default
RUN npm run strapi admin:reset-user-password -- --email=${STRAPI_EMAIL} --password=${STRAPI_PASSWORD}
# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=20s --start-interval=10s --retries=3 CMD [ "executable", "curl", "-f", ${STRAPI_PORT}]
# Create API token, or regenerate it
# RUN node cli.js
# CMD NODE_ENV=production npm run start
CMD NODE_ENV=production npm run develop
# CMD sleep infinity