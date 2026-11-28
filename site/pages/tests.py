"""The site's pages, after import_opensloper (opensloper-make.sh site runs both)."""
import subprocess
import tempfile
from pathlib import Path

from django.test import SimpleTestCase

from .context import version
from .management.commands.import_opensloper import release_version


class PagesTest(SimpleTestCase):
    def test_home_offers_the_app_and_the_download(self):
        page = self.client.get("/")
        self.assertEqual(page.status_code, 200)
        self.assertContains(page, 'href="/design/"')
        self.assertContains(page, 'href="/publish/"')
        self.assertContains(page, 'class="btn btn-solid" href="/publish/"', count=2)
        self.assertContains(page, 'class="btn btn-solid" href="/measurements/"')
        self.assertContains(page, f"Download {version()}")
        self.assertContains(page, "Beta")
        self.assertContains(page, "images/web-publish.webp")
        # The logo and drawings are inlined from the checkout
        self.assertContains(page, "<svg", count=None)

    def test_imported_version(self):
        self.assertRegex(version(), r"^\d+\.\d+\.\d+")

    def test_release_version_is_the_latest_tag(self):
        # A bump on development after a release still offers the release
        with tempfile.TemporaryDirectory() as folder:
            repo = Path(folder)

            def git(*args):
                subprocess.run(["git", "-C", folder, *args], check=True, capture_output=True)

            git("init", "-q")
            git("-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "--allow-empty", "-m", "a")
            self.assertIsNone(release_version(repo))
            git("tag", "v0.8.0")
            git("-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "--allow-empty", "-m", "bump to 0.9.0")
            self.assertEqual(release_version(repo), "0.8.0")

    def test_release_version_without_git(self):
        with tempfile.TemporaryDirectory() as folder:
            self.assertIsNone(release_version(Path(folder)))

    def test_app_needs_its_slash(self):
        for app in ("design", "publish", "measurements"):
            page = self.client.get(f"/{app}")
            self.assertEqual(page.status_code, 301)
            self.assertEqual(page["Location"], f"/{app}/")

    def test_app_is_served_while_developing(self):
        with self.settings(DEBUG=True):
            for app in ("design", "publish", "measurements"):
                page = self.client.get(f"/{app}/")
                self.assertEqual(page.status_code, 200)
                self.assertIn(b'src="main.js"', b"".join(page.streaming_content))

    def test_apps_only_while_developing(self):
        self.assertEqual(self.client.get("/publish/").status_code, 404)
        self.assertEqual(self.client.get("/measurements/").status_code, 404)

    def test_search_engine_files(self):
        self.assertContains(self.client.get("/robots.txt"), "Sitemap: https://www.opensloper.com/sitemap.xml")
        sitemap = self.client.get("/sitemap.xml")
        self.assertContains(sitemap, "https://www.opensloper.com/design/")
        self.assertContains(sitemap, "https://www.opensloper.com/publish/")
        self.assertContains(sitemap, "https://www.opensloper.com/measurements/")
        self.assertEqual(self.client.get("/favicon.svg")["Content-Type"], "image/svg+xml")
