local keys = require("keys")

return {
    "danymat/neogen",
    config = true,
    init = function()
        keys.neogen()
    end,
}
