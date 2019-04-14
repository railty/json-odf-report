module JODFReport

  class Report
    DELIMITERS = ['[', ']']
    
    include Images

    attr_accessor :images, :file, :temp_dir

    def initialize(template_name, data, tmp_dir=nil)
      @file = JODFReport::File.new(template_name, tmp_dir)
      @data = data
    end

    def add_image(name, path)
      @images[name] = path
    end

    def generate(dest = nil, &block)
      @file.create(dest)
      @file.update('content.xml', 'styles.xml') do |txt|
        parse_document(txt) do |doc|
          replace_section(doc, @data)
        end
      end

      if block_given?
        yield @file.path
        @file.remove
      end
      @file.path
    end

    def cleanup
      @file.remove
    end

  private

    def parse_document(txt)
      doc = Nokogiri::XML(txt)
      yield doc
      txt.replace(doc.to_s)
    end
    
    
    def to_placeholder(name)
      if DELIMITERS.is_a?(Array)
        return "#{DELIMITERS[0]}#{name.to_s.upcase}#{DELIMITERS[1]}"
      else
        return "#{DELIMITERS}#{name.to_s.upcase}#{DELIMITERS}"
      end
    end

    def replace_section(node, data)
      data.each do |k, v|
        if v.class == String or v.class == Integer or v.class == Float then
          k = to_placeholder(k)
          txt = node.inner_html
          txt.gsub!(k, sanitize(v))
          node.inner_html = txt
        elsif v.class == Array then
          section = node.xpath(".//text:section[@text:name='#{k}']").first
          if section != nil then
            v.each do |section_data|
              new_section = section.dup
              new_section = replace_section(new_section, section_data)
              section.before(new_section)     
            end
            section.remove
          end

          table = node.xpath(".//table:table[@table:name='#{k}']").first
          if table != nil then
            template_rows = table.xpath("table:table-row")            
            v.each do |rows_data|
              template_rows.each do |row|
                row = replace_section(row.dup, rows_data)
                table.add_child(row)     
              end
            end
            
            template_rows.each do |row|
              row.remove
            end
          end
        end
      end
      return node
    end

    def sanitize(txt)
      txt = html_escape(txt)
      txt = odf_linebreak(txt)
      txt
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

    def html_escape(s)
      return "" unless s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end

    def odf_linebreak(s)
      return "" unless s
      s.to_s.gsub("\n", "<text:line-break/>")
    end

  end

end
