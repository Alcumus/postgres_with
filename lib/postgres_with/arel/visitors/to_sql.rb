module Arel
  module Visitors
    class ToSql < Arel::Visitors::Visitor
      def visit_Arel_Nodes_AsMaterialized o, collector
        collector = visit o.left, collector
        collector << " AS MATERIALIZED "
        visit o.right, collector
      end

      def collect_ctes(children, collector)
        children.each_with_index do |child, i|
          collector << ", " unless i == 0

          case child
          when Arel::Nodes::As, Arel::Nodes::AsMaterialized
            name = child.left.name
            relation = child.right
          when Arel::Nodes::TableAlias
            name = child.name
            relation = child.relation
          end

          collector << quote_table_name(name)
          if child.class == Arel::Nodes::AsMaterialized
            collector <<  " AS MATERIALIZED "
          else
            collector <<  " AS "
          end
          visit relation, collector
        end

        collector
      end
    end
  end
end
