import Vue from 'vue'
import App from './App.vue'
import VueLogger from 'vuejs-logger';
import * as Keycloak from 'keycloak-js';

// Constant definitions
const KeycloakServer = process.env.KEYCLOAK_SERVER || 'http://127.0.0.1:8888/auth';
const KeycloakRealm = process.env.KEYCLOAK_REALM || 'keycloak-demo';
const KeycloakClientID = process.env.KEYCLOAK_CLIENT_ID || 'app-vue';

Vue.use(VueLogger);

let initOptions = {
  url: KeycloakServer, realm: KeycloakRealm, clientId: KeycloakClientID, onLoad: 'login-required'
}

let keycloak = Keycloak(initOptions);

keycloak.init({ onLoad: initOptions.onLoad }).then((auth) => {
  if (!auth) {
    window.location.reload();
  } else {
    Vue.$log.info("Authenticated");

    new Vue({
      el: '#app',
      render: h => h(App, { props: { keycloak: keycloak } })
    })
  }


//Token Refresh
  setInterval(() => {
    keycloak.updateToken(70).then((refreshed) => {
      if (refreshed) {
        Vue.$log.info('Token refreshed' + refreshed);
      } else {
        Vue.$log.warn('Token not refreshed, valid for '
          + Math.round(keycloak.tokenParsed.exp + keycloak.timeSkew - new Date().getTime() / 1000) + ' seconds');
      }
    }).catch(() => {
      Vue.$log.error('Failed to refresh token');
    });
  }, 6000)

}).catch(() => {
  Vue.$log.error("Authenticated Failed");
});


