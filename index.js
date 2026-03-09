const config = {
    load: async function (elmLoaded) {
        const app = await elmLoaded;
    },
    flags: function () {
        return null;
    },
};
export default config;
