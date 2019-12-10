# frozen_string_literal: true

require_relative 'convert_table_cell'

module DocbookCompat
  ##
  # Methods to convert tables.
  module ConvertTable
    include ConvertTableCell

    def convert_table(node)
      [
        convert_table_intro(node),
        convert_table_tag(node, 1),
        convert_colgroups(node),
        convert_parts(node),
        '</table>',
        convert_table_outro(node),
      ].flatten.join "\n"
    end

    def convert_table_intro(node)
      return '<div class="informaltable">' unless node.title

      [
        '<div class="table">',
        %(<p class="title"><strong>#{node.captioned_title}</strong></p>),
        '<div class="table-contents">',
      ]
    end

    def convert_table_outro(node)
      return '</div>' unless node.title

      ['</div>', '</div>']
    end

    def convert_table_tag(node, border)
      [
        '<table',
        %( border="#{border}" cellpadding="4px"),
        node.title ? %( summary="#{node.title}") : nil,
        (width = node.attr 'width') ? %( width="#{width}") : nil,
        '>',
      ].compact.join
    end

    def convert_colgroups(node)
      [
        '<colgroup>',
        node.columns.map { |column| convert_colgroup column },
        '</colgroup>',
      ].flatten
    end

    def convert_colgroup(column)
      %(<col class="col_#{column.attr 'colnumber'}"/>)
    end

    def convert_parts(node)
      head, body, foot = pull_parts node
      result = []
      result += convert_head head unless head.empty?
      result += convert_body body unless body.empty?
      result += convert_foot foot unless foot.empty?
      result
    end

    def pull_parts(node)
      ((_head, head), (_body, body), (_foot, foot)) = node.rows.by_section
      [head, body, foot]
    end

    def convert_head(rows)
      [
        '<thead>',
        rows.map { |row| convert_row row, 'th', false },
        '</thead>',
      ].flatten
    end

    def convert_body(rows)
      [
        '<tbody>',
        rows.map { |row| convert_row row, 'td', true },
        '</tbody>',
      ].flatten
    end

    def convert_foot(rows)
      [
        '<tfoot>',
        rows.map { |row| convert_row row, 'td', false },
        '</tfoot>',
      ].flatten
    end

    def convert_row(row, data_tag, wrap_text)
      [
        '<tr>',
        row.map { |cell| convert_table_cell cell, data_tag, wrap_text },
        '</tr>',
      ].flatten
    end
  end
end
