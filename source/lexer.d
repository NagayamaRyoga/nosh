import std.conv : to;
import std.range : empty, front, popFront;
import std.stdio : File;

private bool isSpace(dchar c)
{
    return c == '\t' || c == ' ';
}

private bool isSpecial(dchar c)
{
    return c == '\n' || c == '\r' || c == '\'' || c == '"' || c == '|';
}

private bool isWord(dchar c)
{
    return !c.isSpace && !c.isSpecial && c != '\0';
}

enum TokenKind
{
    eof,
    eol,
    pipe,
    word,
}

struct Token
{
    TokenKind kind;
    string text;
    bool hasLeadingSpace;

    bool isEof() const
    {
        return kind == TokenKind.eof;
    }

    bool isWord() const
    {
        return kind == TokenKind.word;
    }
}

class Lexer
{
    private File _input;
    private string _buffer;
    private bool _reachedEof;

    this(File input)
    {
        _input = input;
        _buffer = "";
        _reachedEof = false;
    }

    /**
     * トークンを1つ読み進める
     *
     * token :==
     *      SP? (EOF | EOL | SYMBOL | WORD)
     */
    Token read()
    {
        const hasLeadingSpace = skipSpace();

        const c = currentCh();

        if (eof())
        {
            // EOF
            return Token(TokenKind.eof, "", hasLeadingSpace);
        }

        if (c == '\r' || c == '\n')
        {
            // EOL
            return readEol(hasLeadingSpace);
        }

        if (c == '\'')
        {
            // STRING
            return readSingleQuotedString(hasLeadingSpace);
        }

        if (c == '"')
        {
            // DSTRING
            return readDoubleQuotedString(hasLeadingSpace);
        }

        if (c.isSpecial)
        {
            // SYMBOL
            return readSymbol(hasLeadingSpace);
        }

        // WORD
        return readWord(hasLeadingSpace);
    }

    /**
     * 空白文字
     *
     * SP :==
     *      [\t ]+
     */
    private bool skipSpace()
    {
        bool space = false;

        // [\t ]*
        while (!eof && currentCh().isSpace)
        {
            consumeCh();
            space = true;
        }

        return space;
    }

    /**
     * 改行
     *
     * EOL :==
     *      "\r\n" | "\r" | "\n"
     */
    private Token readEol(bool hasLeadingSpace)
    {
        string text = "";

        // '\r'?
        if (currentCh() == '\r')
        {
            text ~= consumeCh();
        }

        // '\n'?
        if (currentCh() == '\n')
        {
            text ~= consumeCh();
        }

        return Token(TokenKind.eol, text, hasLeadingSpace);
    }

    /**
     * 記号
     *
     * SYMBOL :==
     *      "|"
     */
    private Token readSymbol(bool hasLeadingSpace)
    {
        switch (consumeCh())
        {
        case '|':
            return Token(TokenKind.pipe, "|", hasLeadingSpace);

        default:
            throw new Exception("unknown symbol");
        }
    }

    /**
     * シングルクォート文字列
     *
     * STRING :==
     *      '\'' [^']* '\''
     */
    private Token readSingleQuotedString(bool hasLeadingSpace)
    {
        // '\''
        assert(currentCh() == '\'');

        consumeCh();

        // [^']*
        string text = "";

        while (currentCh() != '\'')
        {
            if (eof)
            {
                throw new Exception("unterminated string");
            }

            text ~= consumeCh();
        }

        // '\''
        consumeCh();

        return Token(TokenKind.word, text, hasLeadingSpace);
    }

    /**
     * ダブルクォート文字列
     *
     * DSTRING :==
     *      '"' (\\.|[^"])* '"'
     */
    private Token readDoubleQuotedString(bool hasLeadingSpace)
    {
        // '"'
        assert(currentCh() == '"');

        consumeCh();

        // (\\.|[^"])*
        string text = "";

        while (currentCh() != '"')
        {
            if (eof)
            {
                throw new Exception("unterminated string");
            }

            if (currentCh() == '\\')
            {
                text ~= readEscapedCh();
            }
            else
            {
                text ~= consumeCh();
            }
        }

        // '"'
        consumeCh();

        return Token(TokenKind.word, text, hasLeadingSpace);
    }

    /**
     * 通常のテキスト
     *
     * WORD :==
     *      .+
     */
    private Token readWord(bool hasLeadingSpace)
    {
        string text = "";

        // .*
        while (currentCh().isWord)
        {
            if (currentCh() == '\\')
            {
                text ~= readEscapedCh();
            }
            else
            {
                text ~= consumeCh();
            }
        }

        return Token(TokenKind.word, text, hasLeadingSpace);
    }

    private string readEscapedCh()
    {
        // '\\'
        assert(currentCh() == '\\');

        consumeCh();

        if (currentCh() == '\n' || currentCh() == '\r')
        {
            if (currentCh() == '\r')
            {
                consumeCh();
            }
            if (currentCh() == '\n')
            {
                consumeCh();
            }
            return "";
        }
        else
        {
            return consumeCh().to!string;
        }
    }

    private bool eof()
    {
        return _buffer.empty && _reachedEof;
    }

    private dchar currentCh()
    {
        if (eof)
        {
            return '\0';
        }

        if (!_buffer.empty)
        {
            return _buffer.front;
        }

        if ((_buffer = readln()) is null)
        {
            _reachedEof = true;
            return '\0';
        }

        return _buffer.front;
    }

    private dchar consumeCh()
    {
        const ch = currentCh();

        if (eof())
        {
            return '\0';
        }

        _buffer.popFront();
        return ch;
    }

    private string readln()
    {
        return _input.readln();
    }
}
