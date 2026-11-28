// Keeps an app for offline use through its service worker (sw.js, built from
// serviceWorker.ts beside its page). A new version installs beside the one
// running and waits: an Update button on the toolbar reloads into it, once
// the work not saved is kept (flush), so nothing is lost.
import { STRINGS } from './strings.ts';

export async function keepOffline(
  toolbar: HTMLElement,
  flush: () => Promise<void>,
  failed: (error: unknown) => void,
): Promise<void> {
  if (!('serviceWorker' in navigator)) {
    return;
  }
  const container = navigator.serviceWorker;
  const registration = await container.register('sw.js');
  const update = document.createElement('button');
  update.id = 'update';
  update.type = 'button';
  update.textContent = STRINGS.update;
  update.title = STRINGS.updateHint;
  update.hidden = true;
  toolbar.append(update);
  let reloading = false;
  // The newest worker waiting to take over
  let waiting: ServiceWorker | undefined;
  update.addEventListener('click', () => {
    const next = waiting;
    if (next === undefined) {
      return;
    }
    reloading = true;
    // The work is in the browser before the page goes
    flush()
      .then(() => {
        next.postMessage('skipWaiting');
        return undefined;
      })
      .catch(failed);
  });
  const offer = (worker: ServiceWorker): void => {
    waiting = worker;
    update.hidden = false;
  };
  // Only a worker replacing one that runs the page waits; the first takes over at once
  const offerWhenInstalled = (worker: ServiceWorker): void => {
    worker.addEventListener('statechange', () => {
      if (worker.state === 'installed' && container.controller !== null) {
        offer(worker);
      }
    });
  };
  if (registration.waiting !== null && container.controller !== null) {
    offer(registration.waiting);
  }
  if (registration.installing !== null) {
    offerWhenInstalled(registration.installing);
  }
  registration.addEventListener('updatefound', () => {
    if (registration.installing !== null) {
      offerWhenInstalled(registration.installing);
    }
  });
  const controlled = (): void => {
    // For the tests: the page now loads from the cache
    document.body.dataset.offline = String(container.controller !== null);
  };
  controlled();
  container.addEventListener('controllerchange', () => {
    controlled();
    if (reloading) {
      window.location.reload();
    }
  });
}
