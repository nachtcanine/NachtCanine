var exec = require('cordova/exec');

exports.sendInfo = function (ip, port, info, successCallBack, errorCallBack) {
   exec(successCallBack, errorCallBack, "NachtCanine", "sendInfo", [ip, port, info]);
};


exports.testInfo = function (teststring, successCallBack, errorCallBack) {
   exec(successCallBack, errorCallBack, "NachtCanine", "testInfo", [teststring]);
};
