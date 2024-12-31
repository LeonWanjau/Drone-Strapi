module.exports = () => ({
  "users-permissions": {
    config: {
      ratelimit: {
        interval: 60000,
        max: 100000,
      },
    },
  },
});
