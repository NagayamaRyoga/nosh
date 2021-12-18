import std.range : empty, front, popFront;
import std.stdio : File;
import lexer : Lexer, Token, TokenKind;

class Parser
{
    private Lexer _lexer;
    private Token[] _lookahead;

    this(File input)
    {
        _lexer = new Lexer(input);
        _lookahead = [];
    }

    bool eof() const
    {
        return !_lookahead.empty && _lookahead.front.isEof;
    }

    /**
     * 入力を構文解析する
     *
     * input :==
     *      command_line
     */
    string[] parse()
    {
        // command_line
        return parseCommandLine();
    }

    /**
     * command_line :==
     *      command EOL
     */
    private string[] parseCommandLine()
    {
        // command
        auto args = parseCommand();

        // EOL
        consumeTokenIf(TokenKind.eol);

        return args;
    }

    /**
     * command :==
     *      WORD*
     */
    private string[] parseCommand()
    {
        string[] args = [];

        // WORD*
        while (currentToken().isWord)
        {
            args ~= currentToken().text;
            consumeToken();
        }

        return args;
    }

    private void fillQueue(size_t n)
    {
        while (_lookahead.length < n)
        {
            _lookahead ~= _lexer.read();
        }
    }

    private Token currentToken()
    {
        fillQueue(1);
        return _lookahead.front;
    }

    private void consumeToken()
    {
        fillQueue(1);
        _lookahead.popFront();
    }

    private bool consumeTokenIf(TokenKind kind)
    {
        if (currentToken().kind == kind)
        {
            consumeToken();
            return true;
        }

        return false;
    }
}
