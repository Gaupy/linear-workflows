all : opt

opt :
	ocamlbuild -lib unix script.native

clean :
	ocamlbuild -clean
