import Vue from 'vue'
import App from './App.vue'
import VueLogger from 'vuejs-logger';
import * as Keycloak from 'keycloak-js';
import axios from 'axios';

// Constant definitions
const KeycloakServer = process.env.KEYCLOAK_SERVER || 'https://rh-sso-a-rh-sso-demo.apps.core-ocp.kemo.labs/auth/';
const KeycloakRealm = process.env.KEYCLOAK_REALM || 'petcorp';
const KeycloakClientID = process.env.KEYCLOAK_CLIENT_ID || 'separate-client';
const PetIDServerEndpoint = process.env.PET_ID_SERVER_ENDPOINT || 'https://pet-id-backend-a-sso-app-demo.apps.core-ocp.kemo.labs/app';
const TotalConfig = {'keycloakServer': KeycloakServer, 'keycloakRealm': KeycloakRealm, 'keycloakClientID': KeycloakClientID, 'petIDServerEndpoint': PetIDServerEndpoint}

Vue.use(VueLogger);

let initOptions = {
  url: KeycloakServer, realm: KeycloakRealm, clientId: KeycloakClientID, onLoad: 'login-required'
}

let keycloak = Keycloak(initOptions);

function checkUserProfile(retData, subJ) {
  //let uPro = retData.entities[0].profiles;
  let uProI = retData.entities[0].profiles[0];
  let retD;
  if (uProI.id == 0) {
    retD = {'showProfile': false, 'userID': subJ}
  } else {
    retD = {'showProfile': true, 'Id': uProI.id, 'userID': subJ, 'firstName': uProI.firstname, 'lastName': uProI.lastname, 'avatarURL': uProI.avatar_url, 'email': uProI.email,}
  }
  return retD
}

function getProfileByUUID (sub) {
  return axios
  .get(PetIDServerEndpoint + '/profile?user_id=' + sub)
  .then(response => {
    return checkUserProfile(response.data, sub)
  })
}

keycloak.init({ onLoad: initOptions.onLoad }).then((auth) => {
  if (!auth) {
    window.location.reload();
  } else {
    Vue.$log.info("Authenticated");

    // Query the PetID Profile Server
    console.log("Sub: " + keycloak.subject)

    
    getProfileByUUID(keycloak.subject).then(function (response) {
      let profile = response;
      console.log(response);

        return new Vue({
          el: '#app',
          render: h => h(App, { props: { keycloak: keycloak, profile: profile, appConfig: TotalConfig } })
        })
        //return response.data; // now the data is accessable from here.
    }).catch(function (response) {
        console.log(response);
    });
    /*
    profile = getProfileByUUID(keycloak.subject).then(data => {
      return console.log(data)
    });
    console.log(profile);
    */

    //new Vue({
    //  el: '#app',
    //  render: h => h(App, { props: { keycloak: keycloak, profile: profile, appConfig: TotalConfig } })
    //})
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


