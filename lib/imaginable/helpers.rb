module Imaginable
  module Helpers

    def imaginable_includes_tag
      html = stylesheet_link_tag('fancybox/jquery.fancybox-1.3.4', 'imgareaselect/imgareaselect-animated', 'imaginable')
      html << javascript_include_tag('plupload.full.min', 'jquery.fancybox-1.3.4.pack', 'jquery.imgareaselect.pack', 'imaginable')
    end

  end
end
