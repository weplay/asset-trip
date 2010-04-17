class Dir
   def Dir.empty?(path)
      Dir.entries(path) == [".", ".."]
   end
end