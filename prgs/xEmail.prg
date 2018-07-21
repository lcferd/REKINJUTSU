

define class xEmail as Custom 
	 oEmail = .null.
	
	procedure lSend
		lparameters cSubject, cSetor, cUser, cTo, cBody, cAttachment 
		
		oOutlookApp =  CreateObject("outlook.application")
		this.oEmail = oOutlookApp.createitem(0)
		
		with this.oEmail
			.subject = alltrim(cSubject)
			.to = alltrim(cTo)
			
			.htmlbody = this.cGetHtmlBody(cBody, cUser, cSetor) 
			
			if vartype(cAttachment) = [C] and file(cAttachment)
				.Attachments.Add(cAttachment)
			endif 
			
			.send()
			return
		endwith 
		
		oOutlookApp = .null.
		
		
	
	endproc 
	
	procedure cGetHtmlBody 
		lparameters cBody, cUser, cSetor
		local cReturn, cApresentacao
		
		If Val(Strtran(Substr(Ttoc(Datetime()),12),":", "")) > 120000 
			If Val(Strtran(Substr(Ttoc(Datetime()),12),":", "")) > 180000 
				cApresentacao = "boa noite!"	
			Else
				cApresentacao = "boa tarde!"	
			EndIf 
		Else
			cApresentacao = "bom dia!"
		EndIf 
		
		text to cReturn textmerge noshow 
		<p style='font-family: Segoe UI Semilight; font-size: 14.5; color: #5B5D5A;'><<cApresentacao>><br/><br/><<alltrim(cBody)>><br/><br/>Obrigado!<br/><br/>
		<table><tbody>
		<tr>
		<td width = '50' style='padding: 10;'><img  src = 'https://www.star1crm.com.br/crmstar/custom/iv2018/Logotipo%20Positivo%20STARSOFT%20JPEG.jpg' width = '150' alt = '' border ='0'/></td>
		<td width = '410' style='padding: 10; border-left: 1px #000 solid; font-family: Segoe UI Semilight; font-size: 14.5; color: #5B5D5A;'><<cUser>><br/>
		<<cSetor>><br/>
		Tel: 55 11 4133 2200 <br/>
		<a style='font-family: Segoe UI Semilight; font-size: 14.5; color: rgb(0, 0, 238);' href = 'http://www.starsoft.com.br/' target = '_blank'>www.starsoft.com.br</a></td>
		</tr>
		</tbody></table>
		
		endtext 
		
		return cReturn	
	endproc 
enddefine