import std.range : empty, front, popFront;
import std.stdio : File;

private bool isSpace(dchar c)
{
    return c == '\t' || c == ' ';
}

private bool isWord(dchar c)
{
    return !c.isSpace && c != '\n' && c != '\r' && c != '\0';
}

enum TokenKind
{
    eof,
    eol,
    word,
}

struct Token
{
    TokenKind kind;
    string text;

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
     *      SP? (EOF | EOL | WORD)
     */
    Token read()
    {
        skipSpace();

        const ch = currentCh();

        if (eof())
        {
            // EOF
            return Token(TokenKind.eof, "");
        }

        if (ch == '\r' || ch == '\n')
        {
            // EOL
            return readEol();
        }

        // WORD
        return readWord();
    }

    /**
     * 空白文字
     *
     * SP :==
     *      [\t ]+
     */
    private void skipSpace()
    {
        // [\t ]*
        while (!eof && currentCh().isSpace)
        {
            consumeCh();
        }
    }

    /**
     * 改行
     *
     * EOL :==
     *      "\r\n" | "\r" | "\n"
     */
    private Token readEol()
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

        return Token(TokenKind.eol, text);
    }

    /**
     * 通常のテキスト
     *
     * WORD :==
     *      .+
     */
    private Token readWord()
    {
        string text = "";

        // .*
        while (currentCh().isWord)
        {
            text ~= consumeCh();
        }

        return Token(TokenKind.word, text);
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
