module Imaginable
  module Helpers
    def imaginable_includes_tag
      html = stylesheet_link_tag('imgareaselect/imgareaselect-animated', 'imaginable')
      html << javascript_include_tag('plupload.full.min', 'jquery.imgareaselect.pack', 'imaginable')
    end
  end
end
