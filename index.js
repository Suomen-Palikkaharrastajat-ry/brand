const config = {
    load: async function (elmLoaded) {
        const app = await elmLoaded;
        app.ports.focusMobileNav.subscribe(function () {
            requestAnimationFrame(function () {
                const el = document.getElementById('mobile-nav-active') || document.querySelector('#mobile-nav a');
                if (el) el.focus();
            });
        });
    },
    flags: function () {
        return null;
    },
};
export default config;
