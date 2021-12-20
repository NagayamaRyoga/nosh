import std.format : format;
import std.range : back, empty, front, popFront;
import std.stdio : File;
import ast : Command, CommandElement, PipeCommand, SimpleCommand, Word;
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
     *      EOF
     *      EOL
     *      command_line
     */
    Command parse()
    {
        if (currentToken().isEof)
        {
            // EOF
            return null;
        }

        if (consumeTokenIf(TokenKind.eol))
        {
            // EOL
            return null;
        }

        // command_line
        return parseCommandLine();
    }

    /**
     * command_line :==
     *      pipe_command EOL
     */
    private Command parseCommandLine()
    {
        // pipe_command
        auto command = parsePipeCommand();

        // EOL
        consumeTokenIf(TokenKind.eol);

        return command;
    }

    /**
     * pipe_command :==
     *      pipe_command '|' EOL* command
     *      pipe_command '|&' EOL* command
     *      command
     */
    private Command parsePipeCommand()
    {
        // command
        auto left = parseCommand();

        // ('|' | '|&') EOL* command
        while (currentToken().kind == TokenKind.pipe || currentToken().kind == TokenKind.pipeAll)
        {
            const all = currentToken().kind == TokenKind.pipeAll;

            // '|' | '|&'
            consumeToken();

            // EOL*
            skipEol();

            // command
            auto right = parseCommand();

            left = new PipeCommand(left, right, all);
        }

        return left;
    }

    /**
     * command :==
     *      command_element+
     */
    private Command parseCommand()
    {
        // command_element+
        CommandElement[] elements = [];

        do
        {
            // command_element
            elements ~= parseCommandElement();
        }
        while (currentToken().isWord);

        return new SimpleCommand(elements);
    }

    /**
     * command_element :==
     *      word+
     */
    private CommandElement parseCommandElement()
    {
        // word+
        Word[] words = [];

        do
        {
            // word
            words ~= parseWord();
        }
        while (currentToken().isWord && !currentToken().hasLeadingSpace);

        return new CommandElement(words);
    }

    /**
     * word :==
     *      WORD
     */
    private Word parseWord()
    {
        // WORD
        const token = expectAndConsumeToken(TokenKind.word);

        return new Word(token.text);
    }

    private void skipEol()
    {
        while (consumeTokenIf(TokenKind.eol))
        {
        }
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

    private Token consumeToken()
    {
        const token = currentToken();
        _lookahead.popFront();
        return token;
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

    private Token expectAndConsumeToken(TokenKind expected)
    {
        const token = currentToken();
        if (token.kind != expected)
        {
            throw new Exception("unexpected %s".format(token.kind));
        }

        return consumeToken();
    }
}
