arg = arg or {...}
args = (args~="" and args) or (#arg>0 and table.concat(arg," ")) or "<advice>"

math.randomseed(math.random()+os.time()+os.clock()) --because why not?

ch = {"<",">"} --token chars

base = {}

base.noun = {
    basic = true,
    'TCP', 'IP', 'UDP', 'BGP', 'DNS', 'ARP spoof', 'ARP', 'JavaScript',
    'HTML', 'CSS', 'XML', 'SOAP', 'REST', 'SSL', 'socket', 'BSD', 'linux',
    'MPI', 'OpenMP', 'SYN/ACK', 'kernel', 'ELF', 'COFF', '68000', 'x86',
    'MIPS', 'ethernet', 'MAC', 'C', 'C++', 'Java', 'JSON', 'ruby',
    'python', 'linked list', 'radix trie', 'hash table', 'SQL', 'makefile',
    '/proc', '/dev/null', 'tty', 'regex', 'sed', 'vim', 's/// operation',
    'operation', 'port scanner', 'port scan', 'lookup table', 'anti-<noun>',
    '<verber> manual', '<verber> config', 'IRC', 'IRC bot', 'bootloader',
    'GNU/<noun>',
}

base.verb = {
    basic = false,
    forms =  { verb = 1, verbs = 2, verbed = 3, verber = 4, verbing = 5   },
    tokens = {"verb",   "verbs",   "verbed",   "verber",   "verbing"    },
    getter = function(form)
        if not tonumber(form) then
            form = base.verb.forms[form] or 1
        end
        entry = base.verb.entries[math.random(1,#base.verb.entries)]
        if form~=1 then
            form_s = entry[form]
            if string.sub(form_s,1,1) == "-" then
                return entry[1]..string.sub(form_s,2)
            end
            return form_s
        end
        return entry[1]
    end,
    entries = {
        --to verb        verbs       verbed       verber             verbing
        { 'compile',       '-s',        '-d',        '-r',        'compiling' },
        { 'link',          '-s',       '-ed',       '-er',             '-ing' },
        { 'assemble',      '-s',        '-d',        '-r',       'assembling' },
        { 'load',          '-s',       '-ed',       '-er',             '-ing' },
        { 'boot',          '-s',       '-ed',       '-er',             '-ing' },
        { 'reset',         '-s',     'reset',      '-ter',            '-ting' },
        { 'remove',        '-s',        '-d',        '-r',         'removing' },
        { 'decompile',     '-s',        '-d',        '-r',      'decompiling' },
        { 'unlink',        '-s',       '-ed',       '-er',             '-ing' },
        { 'disassemble',   '-s',        '-d',        '-r',    'disassembling' },
        { 'unload',        '-s',       '-ed',       '-er',             '-ing' },
        { 'parse',         '-s',        '-d',        '-r',          'parsing' },
        { 'archive',       '-s',        '-d',        '-r',        'archiving' },
        { 'cherry-pick',   '-s',       '-ed',       '-er',             '-ing' },
        { 'overwrite',     '-s', 'overwrote',        '-r',      'overwriting' },
        { 'edit',          '-s',       '-ed',       '-or',             '-ing' },
        { 'compute',       '-s',        '-d',        '-r',        'computing' },
        { 'release',       '-s',        '-d',        '-r',        'releasing' },
        { 'transmit',      '-s',      '-ted',      '-ter',            '-ting' },
        { 'receive',       '-s',        '-d',        '-r',        'receiving' },
        { 'analyze',       '-s',        '-d',        '-r',        'analyzing' },
        { 'print',         '-s',       '-ed',       '-er',             '-ing' },
        { 'save',          '-s',        '-d',        '-r',           'saving' },
        { 'erase',         '-s',        '-d',        '-r',          'erasing' },
        { 'install',       '-s',       '-ed',       '-er',             '-ing' },
        { 'scan',          '-s',      '-ned',      '-ner',            '-ning' },
        { 'port scan',     '-s',      '-ned',      '-ner',            '-ning' },
        { 'nmap',          '-s',      '-ped',      '-per',            '-ping' },
        { 'DDOS',         '-es',      '-sed',      '-ser',            '-sing' },
        { 'exploit',       '-s',       '-ed',       '-er',             '-ing' },
        { 'send',          '-s',      'sent',       '-er',             '-ing' },
        { 'write',         '-s',     'wrote',        '-r',          'writing' },
        { 'detect',        '-s',       '-ed',       '-or',             '-ing' },
        { 'sniff',         '-s',       '-ed',       '-er',             '-ing' },

        { 'look up', 'looks up', 'looked up', 'looker upper', 'looking up' },
        { 'check out', 'checks out', 'checked out', 'checker outer', 'checking out' },
        { 'query', 'queries', 'queried', 'querier', 'querying' },
    },

}

base.hack = {
    basic   = false,
    forms   = { hack = 1, hacks = 2, hacked = 3, hacker = 4, hacking = 5 },
    v_forms = { "verb",   "verbs",   "verbed",   "verber",   "verbing"   },
    tokens  = { "hack",   "hacks",   "hacked",   "hacker",   "hacking"   },
    getter  = function(form)
        return "<"..base.hack.v_forms[base.hack.forms[form] or 1].."> <hack_object>"
    end
}

base.hacker = {
    basic   = false,
    getter  = function()
        return "<hack_obect>".."<verber>"
    end
}

base.service = {
    basic = true,
    'Google', 'Amazon', 'Stack Overflow', 'Freenode', 'EFnet', 'Usenet',
    'this old GeoCities page', 'my website', '<person>\'s website',
}

base.hack_object = {
    basic = true,
    'the <noun>', 'a(n) <noun>', 'the victim\'s <noun>', 'some <noun>',
    'a(n) <verber> from <service>', '<service>\'s <noun>',
    'the freeware <noun>', 'a configurable <noun>', 'a working <noun>',
    'a pre-<verbed> <verber>',
}

base.tool = {
    basic = true,
    '<noun> <verber>',
    '<verbed> <noun>',
    '<verber>',
    '<verber> for <nouns>',
    '<verbing> <tool>',
    'thing that <verbs>',
    'thing for <verbing> <nouns>',
    'pre-<noun> <verber>',
    'anti-<noun> <verber>',
    '<verbing> tool',
    '<verber> subsystem',
    'professional <verber>',
    '<verber>-<verber> hybrid',
}

base.tools = {
    basic = true,
    '<noun> <verber>s',
    '<verbed> <nouns>',
    '<verber>s',
    '<verbing> <tools>',
    'things for <verbing>',
    'pre-<noun> <verber>s',
}

base.person = {
    basic = true,
    'Linus Torvalds',
    'Alan Cox',
    'Con Colivas',
    'Ingo Molnar',
    'Hans Reiser',
    'Ulrich Drepper',
    'Larry Wall',
    'William Pitcock',
    'Bill Gates',
    'Ken Thompson',
    'Brian Khernigan',
    'Dennis Ritchie',
    'Eric S. Raymond',
    'Richard M. Stallman',
    'DPR',
    'Sabu',
}

base.system = {
    basic = true,
    'Amiga', 'C-64', 'IBM PC', 'Z80', 'VAX', 'the PDP-8',
}

base.time = {
    basic = true,
    'way back', 'a few years ago', 'in the early 90\'s I think',
    'when everybody had a(n) <verber>',
    'before anybody knew who <person> was',
}

base.advice = {
    basic = true,
    'Try <hacking>.',
    'Did you <hack> first?',
    'Read up on <hacking>.',
    'Check <service> for a(n) <tool>.',
    'See if the <tool> has <hacked> already.',
    'Did you check the <tool> config?',
    'Hm, sounds like a problem with the <tool>.',
    'Doesn\'t look like the <tool> is <hacking>.',
    'Check the "<tool>" wiki.',
    'You probably didn\'t <hack>.',
    'Check the "<tool>" website.',
    '<hack>, then send me the <tool> output.',
    'Pastebin your <tool> config.',
    'I think my <noun> has a(n) <verber>, try that.',
    '<hacking> worked for me.',
    'Did you enable the <tool>?',
    'No, the <tool> <hacks>. You want a(n) <tool>.',
    'Do you have a(n) <tool> installed?',
    'A(n) <tool> is needed to <hack>.',
    '<person> claims you can <hack>.',
    'I heard <person> <hacks> when that happens.',
    'I saw on <service>, you can <hack>.',
    'A(n) <tool> might do the trick.',
    'Make sure to delete your <tool>. That stuff is illegal.',
    'Did you <hack> before you <hacked>?',
    'Where did you <verb> the <tool> to?',
    'I don\'t know. Ask the guy who wrote your <tool>. I think <person>?',
    'Was this with a(n) <tool> or a(n) <tool>?',
    'Please use the official <tool>.',
    'That won\'t work. You can\'t just <hack>.',
    '<hack>, <hack>, and THEN <hack>. Sheesh.',
    'No, don\'t <hack>. <person> recently published a CVE about that.',
    '<verb>, <verb>, <verb>. This is our motto.',
    'Don\'t think too hard about <hacking>. The <tool> will do that.',
    'There\'s a(n) <noun> exploit floating around somewhere. Check <service>.',
    'Simple <tools> cannot <hack>. You need a good, solid <tool>.',
    'I had a(n) <tool> for <system> <time>.',
    'Sounds like you need a(n) <tool>. <person> wrote one for <service>.',
}

function basic_getter(tbl)
    return function()
        return tbl[math.random(1,#tbl)]
    end
end

tags = {} --ties <tag> to respective getter

function multi_token(getter,tokens)
    for k,v in pairs(tokens) do
        tags[v] = getter
    end
end

for k,v in pairs(base) do
    multi_token((v.basic~=true and v.getter) or basic_getter(v), (v.basic~=true and v.tokens ) or {k})
end

function parse(text)
    text = string.gsub(text, ch[1].."([a-z_A-Z]+)"..ch[2],
    function(token)
        return ((tags[token]~=nil and tags[token]) or (function(t) return "?"..t.."?" end))(token)
    end)
    return text
end

ret = args

while (string.find(ret, ch[1].."([a-z_A-Z]+)"..ch[2])) do
    ret = parse(ret)
end


ret = string.gsub(ret, "([aA])%(([nN])%) ([AEFHILMNOURSXaefhilmnoursx])", "%1%2 %3")
ret = string.gsub(ret, "([aA])%([nN]%) ", "%1 ")

print((string.sub(ret,1,1)):upper()..string.sub(ret,2))
