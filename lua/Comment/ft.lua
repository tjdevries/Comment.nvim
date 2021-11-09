---Common commentstring shared b/w mutliple languages
local M = {
    cxx_l = '//%s',
    cxx_b = '/*%s*/',
    hash = '#%s',
    dash = '--%s',
    haskell_b = '{-%s-}',
    fsharp_b = '(*%s*)',
    html_b = '<!--%s-->',
    latex = '%%s',
}

local javascript_special_nodes = {
    comment = { M.cxx_l, M.cxx_b },
    jsx_attribute = { M.cxx_l, M.cxx_b },
    jsx_element = { '{/* %s */}', '{/* %s */}' },
    jsx_fragment = { '{/* %s */}', '{/* %s */}' },
    jsx_opening_element = { M.cxx_l, M.cxx_b },
    call_expression = { M.cxx_l, M.cxx_b },
    statement_block = { M.cxx_l, M.cxx_b },
}

---Lang table that contains commentstring (linewise/blockwise) for mutliple filetypes
---@type table { filetype = { linewise, blockwise } }
local L = {
    bib = { M.latex },
    c = { M.cxx_l, M.cxx_b },
    cmake = { M.hash, '#[[%s]]' },
    cpp = { M.cxx_l, M.cxx_b },
    dhall = { M.dash, M.haskell_b },
    dot = { M.cxx_l, M.cxx_b },
    elm = { M.dash, M.haskell_b },
    fsharp = { M.cxx_l, M.fsharp_b },
    go = { M.cxx_l, M.cxx_b },
    graphql = { M.hash },
    groovy = { M.cxx_l, M.cxx_b },
    haskell = { M.dash, M.haskell_b },
    html = { M.html_b, M.html_b },
    idris = { M.dash, M.haskell_b },
    java = { M.cxx_l, M.cxx_b },
    javascript = vim.tbl_deep_extend('keep', { M.cxx_l, M.cxx_b }, javascript_special_nodes),
    javascriptreact = vim.tbl_deep_extend('keep', { M.cxx_l, M.cxx_b }, javascript_special_nodes),
    julia = { M.hash, '#=%s=#' },
    lidris = { M.dash, M.haskell_b },
    lua = { M.dash, '--[[%s--]]' },
    nix = { M.hash, M.cxx_b },
    ocaml = { M.fsharp_b, M.fsharp_b },
    plantuml = { "'%s", "/'%s'/" },
    purescript = { M.dash, M.haskell_b },
    python = { M.hash }, -- Python doesn't have block comments
    php = { M.cxx_l, M.cxx_b },
    rust = { M.cxx_l, M.cxx_b },
    scala = { M.cxx_l, M.cxx_b },
    sh = { M.hash },
    sql = { M.dash, M.cxx_b },
    swift = { M.cxx_l, M.cxx_b },
    terraform = { M.hash, M.cxx_b },
    tex = { M.latex },
    toml = { M.hash },
    typescript = vim.tbl_deep_extend('keep', { M.cxx_l, M.cxx_b }, javascript_special_nodes),
    typescriptreact = vim.tbl_deep_extend('keep', { M.cxx_l, M.cxx_b }, javascript_special_nodes),
    vim = { '"%s' },
    xml = { M.html_b, M.html_b },
    yaml = { M.hash },
    zig = { M.cxx_l }, -- Zig doesn't have block comments. waaaattttt!
}

return setmetatable({}, {
    __index = {
        set = function(k, v)
            L[k] = type(v) == 'string' and { v } or v
        end,

        get = function(lang, ctype)
            local l = L[lang]
            return l and l[ctype]
        end,

        lang = function(lang)
            return L[lang]
        end,

        calculate = function(ctx)
            P(ctx)
            local lang = L[ctx.lang]
            if not lang then
                return
            end

            if not ctx.node then
                return lang[ctx.ctype] or lang[1]
            end

            local config = lang[ctx.node:type()]
            if not config then
                return lang[ctx.ctype] or lang[1]
            end

            -- TODO: Dunno if this is any good or not.
            return config[ctx.ctype] or config[1]
        end,
    },
    __newindex = function(this, k, v)
        this.set(k, v)
    end,
    __call = function(this, langs, spec)
        for _, lang in ipairs(langs) do
            this.set(lang, spec)
        end
    end,
})
