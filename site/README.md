# opensloper.com

The project's website: the home page and, under `/design/`, the web Design
app (a beta, `web/`), with the web Publish app, also a beta, under
`/publish/` and the web Measurements app, likewise, under `/measurements/`. A Django 5.2 site with no database: it keeps no
accounts, patterns or measurements (`documents/design/web-version.md`,
Server). Its own packages are pinned in `requirements.txt`.

| Path | What it is |
| --- | --- |
| `opensloper_site/` | Settings (from the environment in production), addresses, WSGI |
| `pages/` | The pages' templates, CSS and pictures, their tests, and `import_opensloper` |
| `deploy/` | `deploy.sh`, the gunicorn service, its environment file and the Apache directives |
| `imported/` | What `import_opensloper` copied from the checkout (not in git) |

## Developing

```
./opensloper-make.sh web            # build the web Design app, with FPC trunk (web/README.md)
./opensloper-make.sh site --serve   # import it into the site, check, test, and serve at 127.0.0.1:8000
```

`site` installs Django into the repository's `venv`, then runs
`manage.py import_opensloper`, which copies the logo, app icons, tutorial
drawings and version from the checkout, and `web/out/design`,
`web/out/publish` and `web/out/measurements`, into
`imported/`. The version is the latest release, the newest `v*` tag in the
checkout's history, so a version bump on `development` does not show until
its release is tagged; without git it is `APP_VERSION`. Run it again after any of those change. While developing,
Django serves the app and the static files; in production Apache does.

The screenshots in `pages/static/pages/images/` are 1280x800 WebP:

- `web-design`, the hero: the web Design app in headless Chromium with the
  bodice block example opened from the Examples box, point SB chosen in the
  Objects tab, then the Properties tab shown.
- `web-publish`, in the browser section: the web Publish app in headless
  Chromium at 1280x800, with `docs/examples/circle-skirt/circle-skirt.sloper`
  and `docs/examples/measurements/size-table.slm` opened together, then
  Pack pieces in the Pieces tab.
- One per desktop app in The apps section (`measurements-app`,
  `design-features`, `publish-app`, `drape-app`), and `design-app`, taken in
  Xvfb (`Xvfb :78 -screen 0 1280x800x24`) with no window manager, the light
  Qt style (`env -u QT_QPA_PLATFORMTHEME`), a throwaway `HOME`, View → Labels
  → Contextual, the window moved to 0,0 and sized 1280x800 with `xdotool`,
  and `import -window root`, then `magick shot.png -quality 82 x.webp`:
  - design-app: `docs/examples/bodice-block/bodice-block.sloper`, View →
    Piece Fills on, zoom to fit, Garment tab open.
  - design-features: the same, Features tab open with Zip chosen, centre
    back edge selected.
  - measurements-app: `docs/examples/measurements/size-table.slm`.
  - publish-app: `docs/examples/circle-skirt/circle-skirt.sloper`, Pieces
    tab, Pack pieces, zoom to fit.
  - drape-app: `docs/examples/bodice-block/bodice-block.sdrape`, the view
    turned a little by dragging so the back piece shows.

`og-image.jpg` is the link-preview picture, cut from `design-app`:
`magick design-app.webp -resize 1200x -gravity north -crop 1200x630+0+0 +repage -strip -quality 85 og-image.jpg`.

## Deploying

The site runs under gunicorn as a systemd service on the ISPConfig server,
with Apache in front. The web app's Wasm engine needs the FPC trunk
cross-compiler, so the site is built here and copied over, `imported/`
included, by `deploy/deploy.sh`. The server's details stay out of git, in
`deploy/deploy.local.sh` (copy `deploy.local.sh.example`): `SITE_HOST`, an
`~/.ssh/config` entry for the site's SSH account, and `SITE_DIR`, a folder
outside the public `web` folder, such as the ISPConfig site's `private`
folder, which Apache serves `/static/`, `/design/`, `/publish/` and `/measurements/` from. The environment
file is `SITE_DIR.env`, beside it. The SSH account is the site's web user,
the one the service runs as, so deploying needs no root.

Each release:

```
site/deploy/deploy.sh      # builds with web --strip-names and site first; --no-build skips them
```

The script copies `site/` with rsync, then on the server makes the venv if
need be, installs `requirements.txt`, writes the environment file with a new
secret key the first time, fills in the service and Apache directives for the
server (their `@SITE_DIR@`, `@SITE_USER@` and `@SITE_GROUP@`) in its copies
there, runs `collectstatic`, and reloads gunicorn with a HUP if
the service is running.

First time, as root on the server, after the first `deploy.sh`:

1. Copy `SITE_DIR/deploy/opensloper-site.service` to
   `/etc/systemd/system/`, then
   `systemctl daemon-reload && systemctl enable --now opensloper-site`.
2. Paste `SITE_DIR/deploy/apache-directives.conf` into the site's
   Apache Directives in ISPConfig, and turn on its Let's Encrypt certificate.

The old static page's files in the site's `web` folder (`index.html`,
`.htaccess` and the rest) are no longer used once the directives are in
place, and can be removed.
