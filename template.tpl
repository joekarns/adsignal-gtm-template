___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "AdSignal Tracking Pixel",
  "brand": {
    "id": "brand_dummy",
    "displayName": "AdSignal",
    "thumbnail": ""
  },
  "description": "Loads the AdSignal tracking pixel and fires a pageview event. Use this tag to install the AdSignal pixel on your site via Google Tag Manager.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "pixelId",
    "displayName": "Pixel ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "REGEX",
        "args": [
          "^px_[a-zA-Z0-9]+$"
        ]
      }
    ],
    "help": "Your AdSignal Pixel ID (e.g. px_abc123). Find this in your AdSignal dashboard under Pixel Setup.",
    "valueHint": "px_"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const injectScript = require('injectScript');
const setInWindow = require('setInWindow');
const callInWindow = require('callInWindow');
const copyFromWindow = require('copyFromWindow');
const createQueue = require('createQueue');
const queryPermission = require('queryPermission');

const pixelId = data.pixelId;
const scriptUrl = 'https://pixel.flb7.com/p.js';

// Initialize the _as queue before the script loads so early calls are buffered
const pushToQueue = createQueue('_as');

// Inject the pixel script
if (queryPermission('inject_script', scriptUrl)) {
  injectScript(scriptUrl, function() {
    log('AdSignal: pixel script loaded');

    // Initialize with the Pixel ID
    const adsignal = copyFromWindow('adsignal');
    if (typeof adsignal === 'function') {
      callInWindow('adsignal', 'init', pixelId);
      callInWindow('adsignal', 'track', 'pageview');
    } else {
      // Fallback: push to the _as queue directly
      pushToQueue({ type: 'init', pixelId: pixelId });
      pushToQueue({ type: 'pageview' });
    }

    log('AdSignal: initialized with Pixel ID ' + pixelId);
    data.gtmOnSuccess();
  }, function() {
    log('AdSignal: failed to load pixel script');
    data.gtmOnFailure();
  }, scriptUrl);
} else {
  log('AdSignal: permission denied for script injection');
  data.gtmOnFailure();
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "vpiId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "vpiId": "2"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://pixel.flb7.com/p.js"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "vpiId": "3"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_as"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "adsignal"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Tag fires successfully with valid Pixel ID
  code: |-
    const mockData = {
      pixelId: 'px_test123'
    };

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onSuccess();
    });

    mock('copyFromWindow', function(key) {
      if (key === 'adsignal') return function() {};
      return undefined;
    });

    mock('callInWindow', function() {});

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
    assertApi('injectScript').wasCalledWith(
      'https://pixel.flb7.com/p.js',
      jasmine.any(Function),
      jasmine.any(Function),
      'https://pixel.flb7.com/p.js'
    );

- name: Tag fails when script cannot be loaded
  code: |-
    const mockData = {
      pixelId: 'px_test123'
    };

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onFailure();
    });

    runCode(mockData);

    assertApi('gtmOnFailure').wasCalled();

- name: Tag uses queue fallback when adsignal function is not available
  code: |-
    const mockData = {
      pixelId: 'px_test123'
    };

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onSuccess();
    });

    mock('copyFromWindow', function(key) {
      return undefined;
    });

    let queueItems = [];
    mock('createQueue', function(key) {
      return function(item) {
        queueItems.push(item);
      };
    });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();


___NOTES___

AdSignal Tracking Pixel for Google Tag Manager
https://www.flb7.com

This template loads the AdSignal pixel script and initializes it with your
Pixel ID. It automatically tracks a pageview event each time the tag fires.

For conversion tracking and custom events, use the AdSignal JavaScript API
directly or create additional Custom HTML tags.
