class SummaryPage < ActiveRecord::Base
    
     #----pie_chart for all invoice ----#
    def self.invoice_all(start_date, end_date, current_user)
        @invoices = self.get_invioce(start_date, end_date, current_user)
        invoiceIds = @invoices.pluck(:id)
        earlyCount = self.early_payment(invoiceIds).length
        invoice_count = self.count_of_invoice(@invoices)
        @data = invoice_count.push(earlyCount)
        @total_invoices = @invoices.count
        return @data, @total_invoices
    end
    
    #----pie_chart for invoice amount ----#
    def self.invoice_pie_amount(start_date, end_date, current_user)
        @invoices = self.get_invioce(start_date, end_date, current_user)
        invoiceIds = @invoices.pluck(:id)
        @sum_early =  self.early_payment(invoiceIds).sum(:amount).round(2)
        invoice_amount = self.get_invioce_amount(@invoices)
        @amout_pie_data = invoice_amount.push( @sum_early)
        return @amout_pie_data
    end
    
    #----bar_chart for  all invoice ----#
    def self.invoice_all_bar(start_date, end_date, current_user)
        @paidInvioce = []
        @pendingInvioce = []
        @partialInvioce = []
        @earlyInvioce =   []
        if start_date.month == end_date.month
            @start_date = start_date
            @end_date = end_date
            @invoices = self.get_invioce(@start_date, @end_date, current_user)
            invoiceIds = @invoices.pluck(:id)
            earlyCount = self.early_payment(invoiceIds).length
            @earlyInvioce << earlyCount
            invoice_count = self.count_of_invoice(@invoices)
            @paidInvioce << invoice_count[0]
            @pendingInvioce << invoice_count[1]
            @partialInvioce  << invoice_count[2]
        else
            no_of_months = (end_date.year - start_date.year) * 12 + end_date.month - start_date.month - (end_date.day >= start_date.day ? 0 : 1)
            (0..no_of_months).each_with_index do |number, index|
                if index == 0
                    @start_date = start_date
                    @end_date = start_date.end_of_month
                end
                if index > 0
                    next_date = @end_date.next_month.at_beginning_of_month
                    next_date_month = next_date.month
                    @start_date = next_date
                    if  next_date_month == end_date.month
                         @end_date = end_date
                        
                    else
                        next_end_date = next_date.end_of_month 
                        @end_date = next_end_date
                    end
                end
                @invoices = self.get_invioce(@start_date, @end_date, current_user)
                invoiceIds = @invoices.pluck(:id)
                earlyCount = self.early_payment(invoiceIds).length
                @earlyInvioce << earlyCount
                invoice_count = self.count_of_invoice(@invoices)
                @paidInvioce << invoice_count[0]
                @pendingInvioce << invoice_count[1]
                @partialInvioce  << invoice_count[2]
                
            end 
        end 
        @bar_data = [@paidInvioce , @pendingInvioce, @partialInvioce, @earlyInvioce ]
        return @bar_data
    end
    
    #----bar_chart for invoice amount----#
    def self.invoice_bar_amount(start_date, end_date, current_user)
        @total_invioce_sum = []
        @paid_invioce_sum = []
        @pending_invioce_sum = []
        @early_invioce_sum =   []
        if start_date.month == end_date.month
            @start_date = start_date
            @end_date = end_date
            @invoices = self.get_invioce(@start_date, @end_date, current_user)
            invoiceIds = @invoices.pluck(:id)
            sum_early =  self.early_payment(invoiceIds).sum(:amount).round(2)
            @early_invioce_sum << sum_early
            invoice_amount = self.get_invioce_amount(@invoices)
            @total_invioce_sum << invoice_amount[0]
            @paid_invioce_sum << invoice_amount[1]
            @pending_invioce_sum  << invoice_amount[2]
        else
            no_of_months = (end_date.year - start_date.year) * 12 + end_date.month - start_date.month - (end_date.day >= start_date.day ? 0 : 1)
            (0..no_of_months).each_with_index do |number, index|
                if index == 0
                    @start_date = start_date
                    @end_date = start_date.end_of_month
                end
                if index > 0
                    next_date = @end_date.next_month.at_beginning_of_month
                    next_date_month = next_date.month
                    @start_date = next_date
                    if  next_date_month == end_date.month
                         @end_date = end_date
                        
                    else
                        next_end_date = next_date.end_of_month 
                        @end_date = next_end_date
                    end
                end
                @invoices = self.get_invioce(@start_date, @end_date, current_user)
                invoiceIds = @invoices.pluck(:id)
                sum_early =  self.early_payment(invoiceIds).sum(:amount).round(2)
                @early_invioce_sum << sum_early
                invoice_amount = self.get_invioce_amount(@invoices)
                @total_invioce_sum << invoice_amount[0]
                @paid_invioce_sum << invoice_amount[1]
                @pending_invioce_sum  << invoice_amount[2]
            end 
        end 
            
        @bar_amount_data = [@total_invioce_sum , @paid_invioce_sum, @pending_invioce_sum, @early_invioce_sum ]
        return @bar_amount_data
    end


private

    #-------get invoice based upon roles and dates----------#
    def self.get_invioce(start_date, end_date, current_user)
        start_date = start_date.to_date 
        end_date = end_date.to_date
        if current_user.roles_mask == 2
            @invoice = Invoice.where({user_id: current_user.id})
        elsif current_user.roles_mask == 4
            @invoice = Invoice.where({client: current_user.id})
        end
        @invoices = @invoice.where('status = "send" AND DATE(created_at) >=? AND DATE(created_at) <= ?', start_date, end_date)
        return @invoices 
    end

    #----------invoice with early payments-------#
    def self.early_payment(invoiceIds)
        return @earlyCount =  InvoicePaid.all.where(:invoice_id => invoiceIds.split(","),  :status => 'pending' )
    end

    #----------get count of each invoice-------#
    def self.count_of_invoice(invoices)
        @invoices = invoices
        @paidCount = 0;
        @pendingCount = 0;
        @partialCount = 0;
        @invoices.each do |invoice|
            total_amount = invoice.amount.to_f
            paid_amount = InvoicePaid.where(:status => "paid", :invoice_id => invoice.id).sum(:amount).to_f
            amount_to_pay = (0.85 * total_amount).to_f
            if paid_amount > 0 && paid_amount <= amount_to_pay
                @partialCount = @partialCount + 1
            elsif paid_amount > 0 && paid_amount >= amount_to_pay
                @paidCount = @paidCount + 1
            else
                @pendingCount = @pendingCount + 1
            end
        end
        @data = [@paidCount, @pendingCount, @partialCount]
        return @data
    end
    
    #----------get amount as per status -------#
    def self.get_invioce_amount(invoices)
        @total_invoice_amount = 0
        @total_paid_amount = 0
        @pending_amount = 0
        @total_invoice_amount = @invoices.sum(:amount).to_f
        @invoices.each do |invoice|
            @total_amount = invoice.amount.to_f
            paid_amount = InvoicePaid.where(:status => "paid", :invoice_id => invoice.id).sum(:amount).to_f
            @total_paid_amount = @total_paid_amount + paid_amount
            sum_pending = @total_amount - paid_amount
            @pending_amount = @pending_amount + sum_pending
        end
        @pie_data = [@total_invoice_amount.round(2), @total_paid_amount.round(2), @pending_amount.round(2)]
        return @pie_data
    end

end
