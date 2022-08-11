def initialize_mt5():
    import MetaTrader5 as mt5
    if not mt5.initialize(login=90404218, password="MThs@&04@@", server="OramaDTVM-Server" ): # demo
    #if not mt5.initialize(login=3005496931, password="sSulA86c", server="Rico-PRD"):  # demo
    #if not mt5.initialize(login=5496931, password="J7ce1Z75", server="Rico-PRD"):
    #if not mt5.initialize(login=404218, password="C2a5p27", server="OramaDTVM-Server" ):
        print("initialize() failed, error code =", mt5.last_error())
        quit()

    #for symbol in list_symbols:
    #    #print(symbol)
    #    symbol_info = mt5.symbol_info(str(symbol))

    #    if symbol_info is None:
    #        print(symbol, "not found, can not call order_check()")
    #        mt5.shutdown()
    #        quit()