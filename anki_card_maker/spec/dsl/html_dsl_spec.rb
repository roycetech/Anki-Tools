require './lib/dsl/html_dsl'


describe HTMLDSL do


  let(:answer_only) do
    html :span, :answer, 'Answer Only'
  end

  context 'empty' do
    subject do 
      html :div do
      end
    end

    it 'return "<div></div>"' do
      expect(subject).to eq('<div></div>')
    end
  end

  context 'one-liner' do
    it 'is supported' do
      expect(answer_only).to eq('<span class="answer">Answer Only</span>')
    end
  end

  context 'empty with class' do
   subject do 
      html :div, :main do
      end
    end
    it 'return "<div class=\"main\"></div>"' do
      expect(subject).to eq('<div class="main"></div>')
    end
  end


  context 'with self closing child' do
   subject do 
      html :div, :main do
        br
      end
    end
    it 'is supported' do
      expect(subject).to eq(
        ['<div class="main">', '  <br>', '</div>'].join("\n"))
    end
  end


  context 'with nested block' do
    subject do 
      html(:div) do
        code :well do
          text 'pass'
        end
      end
    end
    it 'is supported' do
      expect(subject).to eq(
        [ '<div>', 
          '  <code class="well">', 
          '    pass',
          '  </code>', 
          '</div>'].join("\n"))
    end
  end

  context 'with nested block and self-closing tag' do
    subject do 
      html(:div) do
        code :well do
          text 'pass'
        end
        hr
      end
    end
    it 'is supported' do
      expect(subject).to eq(
        [ '<div>', 
          '  <code class="well">', 
          '    pass',
          '  </code>',
          '  <hr>', 
          '</div>'].join("\n"))
    end
  end


  context 'with nested one-liner' do
    subject do 
      html(:div) do
        span :answer, 'Answer Only'
      end
    end
    it 'is supported' do
      expect(subject).to eq(
        [ '<div>', 
          '  <span class="answer">Answer Only</span>', 
          '</div>'].join("\n"))
    end
  end


  describe  '#merge' do

    subject do
      # WET because, could not reference the outer subject in this scope
      one_liner = html :span, :answer, 'Answer Only'
      html(:div) do
        code :well do
          text 'pass'
        end
        br
        merge(one_liner)
      end
    end

    it 'is supported' do
      expect(subject).to eq(
        [ '<div>', 
          '  <code class="well">', 
          '    pass',
          '  </code>',
          '  <br>',
          '  <span class="answer">Answer Only</span>',
          '</div>'].join("\n"))
    end

  end  # #merge


end # class