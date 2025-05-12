const AppPermission = {
  CAMERA: "camera",
  GALLERY: "gallery",
  NOTIFICATION: "notification",
  LOCATION: "location",
};

class AppBridge {
  constructor() {
    this._seqNo = 0; // Use a protected-like naming convention
    this._returnMap = new Map(); // Use a protected-like naming convention
  }

  _onListenAppBridgeMessage(msg) {
    const { method, seq, resultOk, data, error } = msg;

    const waitPromise = this._returnMap.get(seq);
    if (!waitPromise) {
      console.error(`No promise found for seq: ${seq}`);
      return;
    }

    if (resultOk) {
      waitPromise.resolve(data);
    } else {
      waitPromise.reject(error);
    }
    this._returnMap.delete(seq);
  }

  _sendMessageToAppBridge(msg) {
    if (typeof appBridgeChannel === "undefined") {
      console.error("appBridgeChannel is not defined!");
      return;
    }
    appBridgeChannel.postMessage(msg);
  }

  _createPromise(method, params = {}) {
    return new Promise((resolve, reject) => {
      const seq = this._seqNo++;
      this._returnMap.set(seq, { resolve, reject });

      this._sendMessageToAppBridge(
        JSON.stringify({
          method,
          seq,
          params,
        })
      );
    });
  }

  getDeviceInfo() {
    return this._createPromise("getDeviceInfo");
  }

  concat(a, b) {
    return this._createPromise("concat", { a, b });
  }

  checkPermission(
    permissions = [
      AppPermission.CAMERA,
      AppPermission.GALLERY,
      AppPermission.LOCATION,
      AppPermission.NOTIFICATION,
    ]
  ) {
    return this._createPromise("checkPermission", { permissions });
  }
}

const appBridge = new AppBridge();
window.appBridge = appBridge;

export { appBridge, AppPermission };
