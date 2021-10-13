<template>
  <div id="app">
    <div class="profileInfo" v-if="profile.showProfile">
      <img src="./assets/logo.png">
      <h1>{{ msg }}</h1>
        <img style="max-width:80px;max-height:80px;border-radius:50%;" :src="profile.avatarURL" />
      <h2>
        <span>{{keycloak.idTokenParsed.preferred_username}}</span>
      </h2>
      <div>
        <table style="margin:0 auto;">
          <tbody>
            <tr>
              <td><strong>First Name:</strong></td>
              <td>{{profile.firstName}}</td>
            </tr>
            <tr>
              <td><strong>Last Name:</strong></td>
              <td>{{profile.lastName}}</td>
            </tr>
            <tr>
              <td><strong>Email:</strong></td>
              <td>{{profile.email}}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <button class="btn" @click="keycloak.logout()">Logout</button>
      </div>
      <div id="wrapper">
        <div class="jwt-token">
          <h3 style="color: black;">JWT Token</h3>
          {{keycloak.idToken}}
        </div>
        <div class="jwt-token">
          <h3 style="color: black;">Info</h3>
          <ul>
            <li>clientId: {{keycloak.clientId}}</li>
            <li>Auth Server Url: {{keycloak.authServerUrl}}</li>
          </ul>
        </div>
      </div>
      <h2>Essential Links</h2>
      <ul>
        <li><a href="https://keycloak.org" target="_blank">Keycloak</a></li>
        <li><a href="https://github.com/keycloak/keycloak-quickstarts" target="_blank">Code Repo</a></li>
        <li><a href="https://twitter.com/keycloak" target="_blank">Twitter</a></li>
      </ul>
    </div>
    <div class="profileInfo" v-else="profile.showProfile">
      
      <h1>Create your profile</h1>
      <h2>User: {{keycloak.idTokenParsed.preferred_username}}
        <button class="btn" @click="keycloak.logout()">Logout</button></h2>
      <div>
      </div>
        <form id="setup-form" style="margin-top:2rem;" @submit.prevent="processForm">
          <table style="margin:0 auto;">
            <tbody>
              <tr class="field">
                <td style="text-align:left;min-width:10vw;">
                  <label class="label">First Name</label>
                </td>
                <td>
                  <input type="text" class="input" name="first_name">
                </td>
              </tr>
              <tr class="field">
                <td style="text-align:left;min-width:10vw;">
                  <label class="label">Last Name</label>
                </td>
                <td>
                  <input type="text" class="input" name="last_name">
                </td>
              </tr>
              <tr class="field">
                <td style="text-align:left;min-width:10vw;">
                  <label class="label">Avatar URL</label>
                </td>
                <td>
                  <input type="avatar" class="input" name="avatar">
                </td>
              </tr>
              <tr class="field">
                <td style="text-align:left;min-width:10vw;">
                  <label class="label">Email</label>
                </td>
                <td>
                  <input type="email" class="input" name="email">
                </td>
              </tr>
              <tr class="field">
                <td colspan="2">
                  <!-- submit button -->
                  <div class="field has-text-right" style="margin-top:1rem;">
                    <button type="submit" class="button is-danger">Submit</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </form>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'app',
  props: ['keycloak', 'profile', 'appConfig'],
  data () {
    return {
      msg: 'Welcome to Your PetID',
      profileID: this.profile.userID
    }
  },
  methods: {
    processResponse: function(resP) {
      
      if (resP.data.errors.length > 0) {
        alert('failed');
      } else {
        let nUser = resP.data.entities[0].profiles[0];
        location.reload();
      }
      
    },
    processForm: function() {
      const signupForm = document.getElementById('setup-form');
      const firstNameInput  = signupForm.querySelector('input[name=first_name]').value;
      const lastNameInput  = signupForm.querySelector('input[name=last_name]').value;
      const emailInput = signupForm.querySelector('input[name=email]').value;
      const avatarURLInput = signupForm.querySelector('input[name=avatar]').value;

      let formData = new FormData();

      formData.append('first_name', firstNameInput);
      formData.append('last_name', lastNameInput);
      formData.append('email', emailInput);
      formData.append('avatar_url', avatarURLInput);
      formData.append('user_id', this.$props.keycloak.subject);

      axios.post(this.$props.appConfig.petIDServerEndpoint + '/profile', 
        formData,
        {
          // Config
        }
      ).then(response => (
        this.processResponse(response)
      ));
    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: block;
  margin: 0 10px;
  color: #333;
  font-size: 20px;
}

a {
  color: #42b983;
}

#wrapper {
  display: flex;
  margin-top: 100px;
}

.jwt-token {
  width: 50%;
  display: block;
  padding: 20px;
  margin: 10 0 10px;
  font-size: 13px;
  line-height: 1.42857143;
  color: #333;
  word-break: break-all;
  word-wrap: break-word;
  background-color: #f5f5f5;
  border: 1px solid #ccc;
  border-radius: 4px;
  color: #d63aff;
  font-weight: bolder;
}

.btn {
    color: #fff;
    background-color: #0088ce;
    border-color: #00659c;
    padding: 6px 10px;
    font-size: 14px;
    line-height: 1.3333333;
    border-radius: 1px;
}
</style>
