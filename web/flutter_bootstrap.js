{{flutter_js}}
{{flutter_build_config}}

const startupLoader = document.getElementById('startup-loader');
const startupWatchdog = window.setTimeout(() => {
  if (!startupLoader?.isConnected) return;

  const message = document.createElement('span');
  message.setAttribute('role', 'alert');
  message.textContent = 'Foddu is taking longer than expected to start.';

  const retryButton = document.createElement('button');
  retryButton.type = 'button';
  retryButton.textContent = 'Try again';
  retryButton.addEventListener('click', () => window.location.reload());

  startupLoader.replaceChildren(message, retryButton);
}, 30000);

_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      window.clearTimeout(startupWatchdog);

      if (startupLoader) {
        startupLoader.classList.add('is-hidden');
        window.setTimeout(() => startupLoader.remove(), 200);
      }
    } catch (error) {
      window.clearTimeout(startupWatchdog);
      console.error('Flutter web startup failed:', error);
      if (startupLoader) {
        startupLoader.innerHTML =
          '<span role="alert">Foddu could not start. Please refresh the page.</span>';
      }
    }
  },
});
