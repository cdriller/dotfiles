return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    config = function ()
        local ls = require("luasnip")
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local extras = require("luasnip.extras")
        local rep = extras.rep
        local fmt = require("luasnip.extras.fmt").fmt

        ls.add_snippets("all", {
            s("ternary", {
                -- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
                i(1, "cond"), t(" ? "), i(2, "then"), t(" ::::: "), i(3, "else"),
            }),
        })
        ls.add_snippets("c", {
            s("docstr", fmt([[
            /**
             * @brief {1}
             * 
             * {2}
             *
             * @param {3} {4}
             *
             * @return {5}
             */
            ]], {
                    i(1, "one line summary"),
                    i(2, "detailed explanation"),
                    i(3, "param name"),
                    i(4, "param desc"),
                    i(5, "return value desc"),
                })),
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
            ]], { i(1, "message") })),
            s("header", fmt([[
            #ifndef {1}_H
            #define {2}_H
            {3}
            #endif
            ]], {
                i(1, "macro"),
                rep(1),
                i(2, "content"),
            })),
            s("document", fmt([[
            #include "lib/logging.h"

            #ifdef DEB_ENABLE_GLOBAL
            static const char *pre_debstr = "{}";
            #endif
            #define FILE_DEB_LEVEL DEB_LEVEL_VERB
            ]], {
                i(1, "filename"),
            }))
        })

    end,
}
