function render(t,o){return JST["templates/"+t](o)}function capitalize(t){return t.charAt(0).toUpperCase()+t.substring(1).toLowerCase()}function getCurrentLocation(t){navigator.geolocation?navigator.geolocation.getCurrentPosition(t,function(t){t.code===t.PERMISSION_DENIED?alert("Enable location services to continue."):t.code===t.POSITION_UNAVAILABLE||t.code===t.TIMEOUT?alert("Location is unavailable."):alert("Could not get location.")},{timeout:1e4,enableHighAccuracy:!0}):alert("Current location not supported.")}