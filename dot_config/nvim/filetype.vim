if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  " Data table files: set fdm before reading file (too slow on large files)
  au! BufRead,BufNewFile *.dat    setf datafile
  au! BufReadPre         *.dat    setl fdm=manual

  " filetype specific options
  au! filetype cpp      setl commentstring=//%s
  au! filetype datafile setl nospell nowrap noet ts=20 tw=0 sw=0
  au! filetype help     setl cc=
augroup END
