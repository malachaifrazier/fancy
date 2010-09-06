def class AST {
  def class MessageSend : Node {
    self read_write_slots: ['receiver, 'method_ident, 'args];

    def MessageSend from_sexp: sexp {
      receiver = sexp[1] to_ast;
      message_name = sexp[2] to_ast;
      args = sexp[3] map: |a| { a to_ast };
      AST::MessageSend receiver: receiver method_ident: message_name args: args
    }

    def MessageSend receiver: recv method_ident: mident args: args {
      ms = AST::MessageSend new;
      ms receiver: recv;
      ms method_ident: mident;
      ms args: args;
      ms
    }

    def to_ruby: out indent: ilvl {
      @receiver to_ruby: out indent: ilvl;
      out print: ".";
      @method_ident to_ruby: out;
      out print: "(";
      # output all but last args first, each followed by a comma
      @args empty? if_false: {
        @args [[0,-2]] each: |a| {
          a to_ruby: out;
          out print: ", "
        };
        # then output last arg, not followed by a comma
        @args last to_ruby: out
      };
      out print: ")"
    }
  }
}