//EXģ��
//��������ģ�鴫�������ݽ�������
`include "defines.v"
module ex(

    input wire          rst,

    //����ģ�鴫������Ϣ
    input wire[`AluOpBus]           aluop_i,
    input wire[`AluSelBus]          alusel_i,
    input wire[`RegBus]             reg1_i,
    input wire[`RegBus]             reg2_i,
    input wire[`RegAddrBus]         wd_i,
    input wire                      wreg_i,

	//HI��LO�Ĵ�����ֵ
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,

    //������Ϻ�Ľ��
    output reg[`RegAddrBus]         wd_o,
    output reg                      wreg_o,
    output reg[`RegBus]             wdata_o,

    //������Ϻ�
    output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg                    whilo_o	
);

//�����߼�����Ľ�� 
reg[`RegBus] logicout;
reg[`RegBus] shiftres;
reg[`RegBus] moveres;
reg[`RegBus] HI;
reg[`RegBus] LO;

//����aluop_iָʾ�����������ͽ�������

//LOGIC
always @ (*) begin
    if(rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_OR_OP:begin    //���С���"����
                logicout <= reg1_i | reg2_i;
            end
            
`EXE_AND_OP:begin //and
                logicout <= reg1_i & reg2_i;
            end
            `EXE_NOR_OP:begin //nor
                logicout <= ~(reg1_i | reg2_i);
            end
            `EXE_XOR_OP:begin //xor
                logicout <= reg1_i ^ reg2_i;
            end
            default:begin
                logicout<=`ZeroWord;
            end
        endcase
    end //if
end //always


//SHIFT
always @ (*) begin
    if(rst == `RstEnable)begin
        shiftres <= `ZeroWord;
    end else begin
        case(aluop_i)
            `EXE_SLL_OP:begin
                shiftres <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP:begin
                shiftres <= reg2_i >> reg1_i[4:0];
            end
            `EXE_SRA_OP:begin
                shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftres <= `ZeroWord;
            end
        endcase
    end //IF
end //always

 //�õ����µ�HI��LO�Ĵ�����ֵ���˴�Ҫ���ָ�������������
always @ (*) begin
	if(rst == `RstEnable) begin
		{HI,LO} <= {`ZeroWord,`ZeroWord};
	end else begin
		{HI,LO} <= {hi_i,lo_i};			
	end
end	

//MFHI��MFLO��MOVN��MOVZָ��
always @ (*) begin
	if(rst == `RstEnable) begin
	  	moveres <= `ZeroWord;
	end else begin
	   moveres <= `ZeroWord;
	   case (aluop_i)
	   	`EXE_MFHI_OP:		begin
	   		moveres <= HI;
	   	end
	   	`EXE_MFLO_OP:		begin
	   		moveres <= LO;
	   	end
	   	`EXE_MOVZ_OP:		begin
	   		moveres <= reg1_i;
	   	end
	   	`EXE_MOVN_OP:		begin
	   		moveres <= reg1_i;
	   	end
	   	default : begin
	    end
	   endcase
	end
end	 
		

//����alusel_iָʾ���������ͣ�ѡ��һ����������Ϊ���ս��
always @ (*) begin
    wd_o <= wd_i;       //Ҫд��Ŀ�ļĴ�����ַ
    wreg_o <= wreg_i;
    case(alusel_i)
        `EXE_RES_LOGIC:begin
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT:begin
            wdata_o <= shiftres;
        end
        `EXE_RES_MOVE:		begin
	 		wdata_o <= moveres;
	 	end	
        default:begin
            wdata_o<=`ZeroWord;
        end
    endcase
end
//MTHI��MTLOָ��
always @ (*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;		
	end else if(aluop_i == `EXE_MTHI_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= reg1_i;
		lo_o <= LO;
	end else if(aluop_i == `EXE_MTLO_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= HI;
		lo_o <= reg1_i;
	end else begin
		whilo_o <= `WriteDisable;
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end				
end	
endmodule