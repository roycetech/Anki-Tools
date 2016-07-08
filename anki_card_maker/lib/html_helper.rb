require './lib/html_builder'
require './lib/highlighter/base_highlighter'

require './lib/html/list'
require './lib/html/code'
require './lib/html/inline'

require './lib/html/style_helper'
require './lib/code_detector'
require './lib/markdown'


class HtmlHelper


  HEC_LT = '&lt;'
  HEC_GT = '&gt;'


  attr_reader :front_html, :back_html


  def initialize(highlighter, tag_helper, front_array, back_array)
    @tag_helper = tag_helper
    @highlighter = highlighter

    style_helper = StyleHelper.new(tag_helper)

    builder_front = HtmlBuilder.new
    builder_back = HtmlBuilder.new

    style_helper.apply_common(builder_front)
    style_helper.apply_common(builder_back)
    style_helper.apply_code(builder_back) if CodeDetector.has_code? back_array
    style_helper.apply_code(builder_front) if CodeDetector.has_code? front_array
    style_helper.apply_answer_only(builder_front) if tag_helper.is_back_only?
    style_helper.apply_answer_only(builder_back) if tag_helper.is_front_only?
    style_helper.apply_command(builder_front) if tag_helper.command?
    style_helper.apply_figure(builder_back) if tag_helper.figure?

    builder_front = builder_front.style_e
    builder_back = builder_back.style_e

    html_builder_common = HtmlBuilder.new
      .div('main').lf

    tags = build_tags(back_array)

    builder_front.merge(html_builder_common)

    has_visible_tag = !tag_helper.visible_tags.empty?
    unless tag_helper.is_back_only? or not has_visible_tag
      builder_front.merge(tags)
    end

    if tag_helper.command?
        builder_front
          .div.lf
            .code('command')

        builder_front.text(front_array.inject('') do |result, element|
          result += HtmlBuilder::BR + "\n" unless result.empty?
          result += line_to_html_raw(element)
        end).lf

        builder_front
          .code_e.lf
          .div_e.lf
    else

      Code.new(@highlighter).execute(builder_front, front_array)

    end

    # Process Back Card Html
    builder_back.merge(html_builder_common)

    unless tag_helper.is_front_only? or not has_visible_tag
      builder_back.merge(tags)
    end

    if tag_helper.has_enum?
      ListBuilder.new(@highlighter).execute(builder_back, back_array, tag_helper.ol?)
    elsif tag_helper.figure?
      builder_back
        .pre('fig').lf
          .text(back_array.inject('') do |result, element|
            result += "\n" unless result.empty?
            result += line_to_html_raw(element)
          end).lf
        .pre_e.lf

    else
      Code.new(@highlighter).execute(builder_back, back_array)
    end


    if tag_helper.one_sided?
      answerHtml = HtmlBuilder.new
        .span('answer_only').text('Answer Only').span_e.lf
    end

    if tag_helper.is_front_only?

      builder_back.br.br if builder_back.last_element == 'text' and not builder_back.build.chomp.end_with?('</code></div>')
      builder_back.merge(answerHtml)

    end

    if tag_helper.is_back_only?

      builder_front.br.br if builder_front.last_element == 'text' and not builder_front.build.chomp.end_with?('</code></div>')
      builder_front.merge(answerHtml)
    end


    @front_html = builder_front.div_e.lf.build
    @back_html = builder_back.div_e.lf.build
  end


  # protected

  # build the tags html. <span>tag1</span>&nbsp;<span>tag2</span>...
  def build_tags(card)
    first = true
    tags_html = HtmlBuilder.new
    @tag_helper.find_multi(card)
    @tag_helper.visible_tags.each do |tag|
      tags_html.space unless first
      tags_html.span('tag').text(tag).span_e
      first = false
    end
    tags_html.lf
  end


  # # 1. Find quoted codes and highlight.

  # def detect_inlinecodes(string_line)
  #   re = /([`])((?:\\\1|[^\1])*?)\1/
  #   return_value = string_line.gsub(re) do |token|
  #     inline_code = token[re,2].gsub('\`', '`')
  #     '<code class="inline">' + @highlighter.highlight_all(inline_code) + '</code>'
  #   end

  #   string_line.replace(return_value
  #     .gsub(/í(.*?)í/, '<i>\1</i>'))
  #   return string_line

  # end


  # 1. Find quoted codes and highlight.
  # 2. Find bold markdowns **bold** or __bold__
  # 3. Find italicized markdowns _italic_ or *italic*
  def line_to_html_raw(param_string)

    parser = SourceParser.new

    code_lambda = lambda { |token, regexp|
      inline_code = token[regexp,2].gsub('\`', '`')
      '<code class="inline">' + @highlighter.highlight_all(inline_code) + '</code>'
    }
    parser.regexter('code', /([`])((?:\\\1|[^\1])*?)\1/, code_lambda);

    parser.regexter('bold', Markdown::BOLD[:regexp], Markdown::BOLD[:lambda]);
    parser.regexter('italic', Markdown::ITALIC[:regexp], Markdown::ITALIC[:lambda]);

    param_string = parser.parse(param_string)

    return_value = HtmlUtil.escape(param_string)
    param_string
      .gsub(/í([a-zA-Z ]*)í/, '<i>\1</i>')
      .gsub(/(?: <(=?) )/, ' ' + HEC_LT + '\1 ')
      .gsub(/(?: >(=?) )/, ' ' + HEC_GT + '\1 ')

    if return_value.index('<code>') and return_value.index('</code>')
      pattern = /(.*<code(?: .*)?>)(.*)(<\/code>.*)/
      colored = @highlighter.highlight_all(return_value[pattern, 2])
      return_value[pattern, 1] + colored + return_value[pattern, 3]
    else
      return_value
    end
  end


end
