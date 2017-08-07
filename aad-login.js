/*
 aad-login.js
 Requests a token from Azure AD using username/password
 
 Available under the Apache 2.0 License
 */

// Configuration parameters
const directory = 'aadDirName';
const clientId  = 'aadClientID';
const resource  = '00000002-0000-0000-c000-000000000000';

const username = process.argv[2];
const password = process.argv[3];

if (username && password) {
    const request = {
        tenant           : directory,
        authorityHostUrl : 'https://login.windows.net',
        clientId         : clientId,
        username         : username + '@' + directory,
        password         : password
    };
    
    const Adal    = require('adal-node');
    const context = new Adal.AuthenticationContext(request.authorityHostUrl + '/' + request.tenant);
    
    context.acquireTokenWithUsernamePassword(resource, request.username, request.password, request.clientId, (err, tokenResponse) => {
        console.log(tokenResponse);
        if (err) { // auth failed, not sure of err value so forcing 1/0 here
            process.exit(1);
        }
        process.exit(0);
    });
} else {
    console.log('No username/password provided');
    process.exit(1);
}
