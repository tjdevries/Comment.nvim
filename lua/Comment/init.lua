local C = require('Comment.comment')

return {
    setup = C.setup,
    toggle = C.toggle,
    comment = C.comment,
    uncomment = C.uncomment,
    get_config = function()
        return C.config
    end,
}
