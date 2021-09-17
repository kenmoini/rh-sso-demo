# Red Hat Single Sign On - Initial Setup

With RH SSO deployed, you can now go about configuring:

- **Realms** - Highest-level grouping of related Clients, Users, Identity Providers, etc.
- **Clients** - Clients are applications that can authenticate against a Realm.
- **Identity Providers** - Identity Providers can broker identities from external services, such as Google OAuth, GitHub, etc.
- **Users** - RH SSO can also provide users and their metadata on its own

## 1. Create a Realm

Navigate to the Administration Console - in the upper-left corner of the screen once logged in, under the Red Hat Single Sign On logo, hover over **Master** and click **Add Realm** when the drop-down pops up.

***Give your Realm a Name and click Create***

## 2. Configure the Realm Settings

Before we make other assets, let's configure this Realm since we're here.

- Display Name: `My Realm`
- HTML Display Name: `<strong>My Realm</strong>`
- Click **Save**

The next set of settings for the Realm can vary depending on where your user database is coming from - the Internal User database, LDAP/Kerberos, or an external IdP such as Google/GitHub/etc?

If using the Internal User database then the **Login** tab will have some settings of interest - if using an external provider then these will have no effect.

Similarly, if are relying on Google for account/email verification, then you may not need SMTP settings configured in the **Email** tab - if you are using the Internal user database then an SMTP server would be very useful.

For the sake of this demo, we'll be using the Internal user database - user profile metadata is always stored in a separate database and concerted with a microservice and messaging bus, all of which is part of this demo.

- Click the **Login** tab
- Set the slider to **On** for the following:
  - User registration
  - Email as username
  - Forgot password
  - Remember me
  - Verify email
  - Login with email
- Click **Save**

For this demo we'll need an SMTP server since we're using the internal user database.  Of course, if you didn't verify or enable password resetting then you wouldn't really NEED an SMTP server, but it's still nice to have for the full experience.

If you need an SMTP server, you can likely use GMail's servers: https://support.google.com/a/answer/176600?hl=en#zippy=%2Cuse-the-gmail-smtp-server

The following example will set up GMail SMTP server usage with an account that has two-factor turned on and thus uses an app-specific password.

- Click the **Email** tab
- Host: `smtp.gmail.com`
- Port: `465`
- From: `your.email@gmail.com`
- Set the slider to **On** for the following:
  - Enable SSL
  - Enable StartTLS
  - Enable Authentication
- Username: `your.email@gmail.com`
- Password: `likeDUH`
- Click **Save**

Before you can click the **Test connection** button your Admin user needs to have a Name and Email set on its profile - from the user drop-down in the upper right of the top bar, click your Admin user, then click **Manage Profile**.  Set a Name and Email.

Go back to the Realm, the Email tab, click **Test Connection**.

- Click the **Themes** tab
- Select `rh-sso` for all the Theme options
- Click **Save**

We'll add our own Theme later.

## 3. Create a Client - keycloaktest

Next we'll create a first test client - in the Admin panel, navigate to  **Clients** and click **Create**.  Fill in the following details:

- Client ID: `keycloaktest`
- Client Protocol: `openid-connect`
- Root URL: `https://www.keycloak.org/app/`

With that Client created, we can get the authentication link and test the Realm and Client connection!

Navigate to the newly created Client's **Installation** tab - find the Authentication Link.

Open the webpage [https://www.keycloak.org/app/](https://www.keycloak.org/app/) and enter your configuration. 

Test the sign-in, and you should see something like this:

There is no user configured - you can use the **Register** link to do so.

You'll find that there's an email verification message sent - you can override this for the user in the Admin panel, or you can check the Sent messages of your Gmail user since these messages are often filtered.