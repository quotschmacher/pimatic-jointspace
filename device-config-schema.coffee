module.exports = {
  title: "pimatic-jointspace device config schema"
  JointspaceSourceSelection: {
    title: "JointspaceSourceSelection config options"
    type: "object"
    properties:
      buttons:
        description: "Source Selection Buttons"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            command:
              type: "string"
  }
  JointspaceDirectInput: {
    title: "JointspaceDirectInput config options"
    type: "object"
    properties:
      buttons:
        description: "Buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            command:
              type: "string"
              enum: ["Standby",
                "Back",
                "Find",
                "RedColour",
                "GreenColour",
                "YellowColour",
                "BlueColour",
                "Home",
                "VolumeUp",
                "VolumeDown",
                "Mute",
                "Options",
                "Dot",
                "Digit0",
                "Digit1",
                "Digit2",
                "Digit3",
                "Digit4",
                "Digit5",
                "Digit6",
                "Digit7",
                "Digit8",
                "Digit9",
                "Info",
                "CursorUp",
                "CursorDown",
                "CursorLeft",
                "CursorRight",
                "Confirm",
                "Next",
                "Previous",
                "Adjust",
                "WatchTV",
                "Viewmode",
                "Teletext",
                "Subtitle",
                "ChannelStepUp",
                "ChannelStepDown",
                "Source",
                "AmbilightOnOff",
                "PlayPause",
                "Pause",
                "FastForward",
                "Stop",
                "Rewind",
                "Record",
                "Online"]
            text:
              type: "string"
              description: "if not entered will be filled out automatically"
            id:
              type: "string"
              description: "if not entered will be filled out automatically"
  }
}
