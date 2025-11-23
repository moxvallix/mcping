// MIT: by Ovi
// https://github.com/Ovi/safe-dig/blob/master/index.js
function safeDig(obj, ...args) {
  try {
    return args.reduce((acc, key) => {
      // If the accumulator is null or not an object/array, return null
      if (acc && (typeof acc === 'object' || Array.isArray(acc))) {
        return acc[key] !== undefined ? acc[key] : null; // Explicitly return null when key is not found
      }
      return null; // Return null if acc is not an object or array
    }, obj);
  } catch (e) {
    return null; // Return null in case of an error
  }
}

function runCommand(command, callback) {
  const component = Qt.createComponent("../ui/CustomDataSource.qml");

  const instance = component.createObject(null, {command});
  
  instance.onExited.connect((exitCode, exitStatus, stdout, stderr) => {
    callback(exitCode, exitStatus, stdout, stderr);

    instance.destroy();
  });

  instance.exec();
}

class Option {
  static none() {
    return new Option(undefined);
  }

  static of(value) {
    return new Option(value);
  }

  constructor(value) {
    this._value = value;
  }

  get() {
    return this._value;
  }

  exist() {
    return this._value !== undefined;
  }

  empty() {
    return !this.exist();
  }

  or(callback) {
    if (this.exist()) {
      return this._value;
    } else {
      return callback();
    }
  }

  if(ifCallback, elseCallback = undefined) {
    if (this.empty()) {
      if (typeof elseCallback === "function") elseCallback();

      return;
    }

    ifCallback(this._value)
  }

  expect(error) {
    if (this.exist()) return;

    throw error;
  }
}

export {safeDig, runCommand, Option}