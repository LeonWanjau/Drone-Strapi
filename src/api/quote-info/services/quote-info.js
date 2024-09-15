'use strict';

/**
 * quote-info service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::quote-info.quote-info');
