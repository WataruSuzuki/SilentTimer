module Danger
    class DangerCheckTodoInline < Plugin

        attr_accessor :diff_files
        def diff_files
            return diff_files = (git.modified_files - git.deleted_files) + git.added_files
        end

        def check_todo_inline
            diff_files.each do |target|
                unless target == "Dangerfile"
                    diff = git.diff_for_file(target)

                    index = 0
                    offset = 0

                    diff.patch.each_line do |line|
                        if line.start_with?("+") && ((/\/\/\ Todo/i =~ line) || (/\/\/\Todo/i =~ line))
                            warn("TODOが残っています", file: target, line: (index + offset))
                        end
                        unless offset == 0 || line.start_with?("-")
                            index = index + 1
                        end
                        if line.include? "@@"
                            # Note: diff.patchからinlineコメントするための行数を取得する
                            line = line[line.index("+"), line.length]
                            if line.include?(",")
                                line = line[1, (line.index(",") - 1)]
                                offset = line.to_i
                                index = 0
                            end
                        end
                    end
                end
            end
        end
    end
end
