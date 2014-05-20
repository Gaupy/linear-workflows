type task = {id : int; w : float; c : float; r : float;}

type edge = { id1 : int; id2 : int; }

type dag = { tabTask : task array; sources : int list; tabParents : int list array; tabChildren : int list array; weightSucc : float array; }
val computeWS : dag -> dag

type linearWorkflow = {order : (int * bool) array; sched : (int * bool) array}

type param = {lambda : float; d : float;}
