library ieee;
use ieee.std_logic_1164.all;

entity control_unit_tx is 
	
	port(
		clk, cu_rst : in std_logic;
		cu_wr, cu_tc, cu_stop : in std_logic;
		cu_reg_le, cu_piso_le, cu_piso_se : out std_logic;
		cu_piso_rst, cu_cnt_rst, cu_cnt_le : out std_logic
	);

end entity control_unit_tx;

architecture behavioral of control_unit_tx is

	--type mi permette di definire un segnale di tipo "enumerate", i cui valori
	--sono dichiarati in forma testuale (IDLE, FF_VALID, ...); ad ognuno di questi
	--viene associato un valore binario: essendo 5 i valori, sono necessari almeno 3 bit
	--per codificare ogni valore in modo univoco. Ognuno di questi valori rappresenta 
	--un preciso stato, quindi e' come se la mia control unit avesse un segnale interno,
	--il cui valore definisce lo stato attuale in cui ci troviamo.
	type state is (IDLE, FF_VALID, SH_VALID, CNT_CLR, DONE);

	--una volta definito il tipo (cioe' "state"), devo dichiarare i segnali interni, che 
	--saranno ovviamente di tipo "state"
	signal present_state, next_state : state;

begin
	
	-- processo combinatorio di transizione degli stati, tutti i segnali di stato 
	-- (che entrano nella CU) vanno inseriti nella sensitivity list oltre al 
	-- present_state (cu_rst e' un caso particolare, essendo il reset asincrono della 
	-- CU e' stato inserito nel processo "state_register")
	state_transition_process : process(cu_stop, cu_wr, cu_tc, present_state) is 

	begin
		
		--default value per l'uscita next_state
		next_state <= IDLE;
		
		case present_state is
			when IDLE => 
				if(cu_wr = '1') then
					next_state <= FF_VALID;
				end if;
			
			when FF_VALID => 
				next_state <= SH_VALID;
						 
			when SH_VALID => 
				if(cu_tc = '1') then
					if(cu_stop = '1') then
						next_state <= DONE;
					else
						next_state <= CNT_CLR;
					end if;
				else
					next_state <= SH_VALID;
				end if;
						
			when CNT_CLR => 
				next_state <= SH_VALID;
			
			when DONE => 
				next_state <= IDLE;
			
			when others => 
				next_state <= IDLE;
		end case;
	
	end process;
			
	-- process sequenziale di aggiornamento stato con cu_rst asincrono, quindi nella 
	-- sensitivity list e' presente anche il reset; appena il reset cambia valore, il 
	-- process si attiva e se reset e' '0', lo stato presente passa subito ad "IDLE".
	state_register : process(cu_rst, clk) is
	begin

		if(cu_rst = '0') then
			present_state <= IDLE;
		elsif(clk'event and clk = '1') then
			present_state <= next_state;
		end if;

	end process;
	
	-- process combinatorio, un solo ingresso cioe' "present_state",
	-- tutti i segnali di controllo sono le uscite della CU e di questi 
	-- possono essere forniti dei default value
	output_evaluation : process(present_state) is
	begin
		
		-- default values per le uscite
		cu_reg_le <= '0';
		cu_piso_le <= '0';
		cu_piso_se <= '0';
		cu_cnt_rst <= '0';
		cu_cnt_le <= '0';
		cu_piso_rst <= '0';
		
		case present_state is
			when IDLE => 
				cu_reg_le <= '1';
				cu_piso_rst <= '1';
			
			when FF_VALID => 
				cu_piso_se <= '1';
				cu_piso_le <= '1';
				cu_cnt_rst <= '1';
								  
			when SH_VALID => 
				cu_cnt_le <= '1';
			
			when CNT_CLR => 
				cu_piso_se <= '1';
				cu_cnt_rst <= '1';

			when DONE => 
				cu_cnt_rst <= '1';
			
			when others => 
		end case;
	
	end process;

end architecture behavioral;