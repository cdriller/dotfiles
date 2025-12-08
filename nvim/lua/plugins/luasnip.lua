return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    config = function ()
        local ls = require("luasnip")
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local fmt = require("luasnip.extras.fmt").fmt

        ls.add_snippets("all", {
            s("ternary", {
                -- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
                i(1, "cond"), t(" ? "), i(2, "then"), t(" ::::: "), i(3, "else"),
            }),
        })
        ls.add_snippets("c", {
            s("bspfile", fmt([[
            #include "lib/logging.h"

            #ifdef DEB_ENABLE_GLOBAL
            static const char *pre_debstr = "{}";
            #endif
            #define FILE_DEB_LEVEL DEB_LEVEL_VERB
            ]], {
                i(1, "filename"),
            })),
            s("log", fmt([[
            DPRINT_INFO(FILE_DEB_LEVEL, pre_debstr, " (%s): {}\n", __func__);
            ]], { i(1, "message") }))
        })
    end,
}
