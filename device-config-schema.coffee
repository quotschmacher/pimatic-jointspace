module.exports = {
  title: "pimatic-jointspace device config schema"
  JointspacePowerButton: {
    title: "JointspacePowerButton config options"
    type: "object"
    properties:
      tvIP:
        description: "IP of the TV"
        type: "string"
      buttons:
        description: "Buttons to display"
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
              description: "Command to send"
              type: "string"
  }
}
