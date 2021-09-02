; Create Filled Rectangle

pro FilledRect,x0,y0,xlength,ylength, color=col

   polyfill,[x0,x0+xlength,x0+xlength,x0,x0], [y0,y0,y0+ylength,y0+ylength,y0],color=col

end
