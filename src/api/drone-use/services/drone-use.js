'use strict';

/**
 * drone-use service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::drone-use.drone-use');
