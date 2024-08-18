# docker-jellyfin
Docker container for running a Jellyfin media server behind a Traefik reverse-proxy combined with an Authentik service for authorization

## Docker Setup
1. Initialize config by running init.sh: `./init.sh`
2. Input personal information into `.env`
3. Make sure that Docker network `traefik` exists, `docker network ls`
4. Run `docker compose up` and check logs

## Authentik Setup
1. Open the Authentik Admin Interface
2. Go to `Applications->Providers` and click `Create`
3. Select `OAuth2/OpenID Provider` and click `Next`
4. Enter the following:
   - Name: `Jellyfin Provider`
   - Authorization flow: implicit-consent
   - Client type: `Confidential`
   - Redirect URIs/Origins (RegEx): `https://jellyfin.DOMAIN.COM/sso/OID/redirect/Authentik`
   - Subject mode: `Based on the User's username`
5. Take note of your `Client ID` and `Client Secret` and click `Finish`
6. Go to `Applications->Applications` and lcick `Create`
7. Enter the following:
   - Name: `Jellyfin`
   - Slug: `jellyfin`
   - Provider: `Jellyfin Provider`
   - Launch URL: `https://jellyfin.DOMAIN.COM/sso/OID/start/Authentik`
8. Click `Create`

## Jellyfin Setup
1. Go to your Jellyfin web UI and set up your initial/admin account
2. Log in with said account and go to the `Administrator dashboard` and click on `Plugins->Repositories` in the left-side menu
3. Click `Add`, enter `Name` as `SSO-Auth` and `URL` as `https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json`, click `Save`
4. Go to `Catalog` and install `SSO Authentication`
5. Restart your Jellyfin server `docker compose restart`
6. Go back to `Plugins->My Plugins` and click the `SSO-Auth` plugin
7. Create a provider and enter the following:
    - Name: `Authentik`
    - OID Endpoint: `https://auth.DOMAIN.COM/application/o/jellyfin/.well-known/openid-configuration`
    - OpenID Client ID: Client ID as per the Authentik Setup
    - OID Secret: Client Secret as per the Authentik Setup
    - Enabled: **ON**
    - Enable Authorization by Plugin: **ON**
8. Scroll to the bottom and click `Save`
9. Go to `General` in the left-side menu and scroll down to `Branding`
10. Input the following under `Login disclaimer`:
    ```
    <form action="https://jellyfin.company/sso/OID/start/authentik">
        <button class="raised block emby-button button-submit">
            Sign in with SSO
        </button>
    </form>
    ```
11. Input the following under `Custom CSS code`:
    ```
    a.raised.emby-button {
        padding:0.9em 1em;
        color: inherit !important;
    }

    .disclaimerContainer{
        display: block;
    }
    ```
12. Click `Save` and 

When signing in to Jellyfin there should now be a button at the bottom for `Sign in with SSO`

## Kodi as Jellyfin client
Source: https://jellyfin.org/docs/general/clients/kodi/  

1. Install Kodi via flatpak: `flatpak install tv.kodi.Kodi`
2. Download the [Kodi Jellyfin repository installer](https://kodi.jellyfin.org/repository.jellyfin.kodi.zip)
3. Open Kodi, go to the settings menu and navigate to `Add-on Browser`
4. Click `Install from Zip File` and select the .zip-file downloaded previously (you might need to go to settings and enable `Unknown Sources` first)
5. In the `Add-on Browser` menu select `Install from Repository`
6. Choose `Kodi Jellyfin Add-ons->Video Add-ons->Jellyfin` and click install
7. Go back to the main menu and you should get promted to add a server shortly, select `Manually Add Server` and enter `http://HOSTNAME:8096` where `HOSTNAME` is replaced by the locally resolved hostname for the Jellyfin server
8. Log in with your Jellyfin credentials
9. Select `Add-on (default)` when prompted for `Playback mode`
10. Select which libraries to add and click `OK`
11. Kodi will now start indexing your content