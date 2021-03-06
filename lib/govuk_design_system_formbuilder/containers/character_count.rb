module GOVUKDesignSystemFormBuilder
  module Containers
    class CharacterCount < Base
      def initialize(builder, max_words:, max_chars:, threshold:)
        super(builder, nil, nil)

        fail ArgumentError, 'limit can be words or chars' if max_words && max_chars

        @max_words = max_words
        @max_chars = max_chars
        @threshold = threshold
      end

      def html(&block)
        return yield unless limit?

        tag.div(**options, &block)
      end

    private

      def options
        {
          class: %(#{brand}-character-count),
          data: { module: %(#{brand}-character-count) }.merge(**limit, **threshold).compact
        }
      end

      def limit
        if @max_words
          { maxwords: @max_words }
        elsif @max_chars
          { maxlength: @max_chars }
        end
      end

      def threshold
        { threshold: @threshold }
      end

      def limit?
        @max_words || @max_chars
      end
    end
  end
end
