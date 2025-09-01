import { supabase } from './supabase'
import { ref, onMounted, onUnmounted } from 'vue'

export interface Notificacao {
    id: string
    tipo: 'info' | 'warning' | 'error' | 'success'
    titulo: string
    mensagem: string
    data: string
    lida: boolean
    acao_url?: string
    acao_texto?: string
}

export interface NotificacaoPayload {
    tipo: 'os_urgente' | 'estoque_baixo' | 'veiculo_manutencao' | 'status_atualizado'
    titulo: string
    mensagem: string
    acao_url?: string
    acao_texto?: string
}

class NotificacaoService {
    private channel: any = null
    private notificacoes = ref<Notificacao[]>([])
    private unreadCount = ref(0)

    constructor() {
        this.setupRealtime()
    }

    private setupRealtime() {
        // Canal para notificações em tempo real
        this.channel = supabase
            .channel('notificacoes')
            .on('postgres_changes',
                {
                    event: 'INSERT',
                    schema: 'public',
                    table: 'notificacoes'
                },
                (payload) => {
                    this.handleNovaNotificacao(payload.new as Notificacao)
                }
            )
            .on('postgres_changes',
                {
                    event: 'UPDATE',
                    schema: 'public',
                    table: 'notificacoes'
                },
                (payload) => {
                    this.handleNotificacaoAtualizada(payload.new as Notificacao)
                }
            )
            .subscribe()
    }

    private handleNovaNotificacao(notificacao: Notificacao) {
        this.notificacoes.value.unshift(notificacao)
        this.unreadCount.value++

        // Mostrar notificação do navegador se permitido
        this.showBrowserNotification(notificacao)
    }

    private handleNotificacaoAtualizada(notificacao: Notificacao) {
        const index = this.notificacoes.value.findIndex(n => n.id === notificacao.id)
        if (index !== -1) {
            this.notificacoes.value[index] = notificacao
            if (notificacao.lida) {
                this.unreadCount.value = Math.max(0, this.unreadCount.value - 1)
            }
        }
    }

    private async showBrowserNotification(notificacao: Notificacao) {
        if (!('Notification' in window)) return

        if (Notification.permission === 'granted') {
            new Notification(notificacao.titulo, {
                body: notificacao.mensagem,
                icon: '/favicon.ico',
                tag: notificacao.id
            })
        } else if (Notification.permission !== 'denied') {
            const permission = await Notification.requestPermission()
            if (permission === 'granted') {
                this.showBrowserNotification(notificacao)
            }
        }
    }

    async getNotificacoes(limit: number = 50): Promise<Notificacao[]> {
        try {
            const { data, error } = await supabase
                .from('notificacoes')
                .select('*')
                .order('data', { ascending: false })
                .limit(limit)

            if (error) throw error

            this.notificacoes.value = data || []
            this.unreadCount.value = data?.filter(n => !n.lida).length || 0

            return data || []
        } catch (error) {
            console.error('Erro ao buscar notificações:', error)
            throw error
        }
    }

    async marcarComoLida(id: string): Promise<void> {
        try {
            const { error } = await supabase
                .from('notificacoes')
                .update({ lida: true })
                .eq('id', id)

            if (error) throw error

            // Atualizar estado local
            const notificacao = this.notificacoes.value.find(n => n.id === id)
            if (notificacao && !notificacao.lida) {
                notificacao.lida = true
                this.unreadCount.value = Math.max(0, this.unreadCount.value - 1)
            }
        } catch (error) {
            console.error('Erro ao marcar notificação como lida:', error)
            throw error
        }
    }

    async marcarTodasComoLidas(): Promise<void> {
        try {
            const { error } = await supabase
                .from('notificacoes')
                .update({ lida: true })
                .eq('lida', false)

            if (error) throw error

            // Atualizar estado local
            this.notificacoes.value.forEach(n => n.lida = true)
            this.unreadCount.value = 0
        } catch (error) {
            console.error('Erro ao marcar todas as notificações como lidas:', error)
            throw error
        }
    }

    async criarNotificacao(payload: NotificacaoPayload): Promise<void> {
        try {
            const { error } = await supabase
                .from('notificacoes')
                .insert({
                    tipo: this.mapTipo(payload.tipo),
                    titulo: payload.titulo,
                    mensagem: payload.mensagem,
                    acao_url: payload.acao_url,
                    acao_texto: payload.acao_texto,
                    data: new Date().toISOString(),
                    lida: false
                })

            if (error) throw error
        } catch (error) {
            console.error('Erro ao criar notificação:', error)
            throw error
        }
    }

    private mapTipo(tipo: string): 'info' | 'warning' | 'error' | 'success' {
        const tipoMap: Record<string, 'info' | 'warning' | 'error' | 'success'> = {
            'os_urgente': 'error',
            'estoque_baixo': 'warning',
            'veiculo_manutencao': 'info',
            'status_atualizado': 'success'
        }
        return tipoMap[tipo] || 'info'
    }

    // Notificações automáticas para eventos do sistema
    async notificarOSUrgente(osId: number, veiculoPlaca: string): Promise<void> {
        await this.criarNotificacao({
            tipo: 'os_urgente',
            titulo: 'OS Urgente Criada',
            mensagem: `Nova ordem de serviço urgente criada para o veículo ${veiculoPlaca}`,
            acao_url: `/ordens-servico/${osId}`,
            acao_texto: 'Ver OS'
        })
    }

    async notificarEstoqueBaixo(pecaNome: string, quantidade: number): Promise<void> {
        await this.criarNotificacao({
            tipo: 'estoque_baixo',
            titulo: 'Estoque Baixo',
            mensagem: `Peça ${pecaNome} está com estoque baixo (${quantidade} unidades)`,
            acao_url: '/estoque',
            acao_texto: 'Ver Estoque'
        })
    }

    async notificarStatusVeiculo(veiculoPlaca: string, status: string): Promise<void> {
        await this.criarNotificacao({
            tipo: 'status_atualizado',
            titulo: 'Status do Veículo Atualizado',
            mensagem: `Veículo ${veiculoPlaca} agora está ${status}`,
            acao_url: '/veiculos',
            acao_texto: 'Ver Veículos'
        })
    }

    // Getters para o estado reativo
    getNotificacoesReativas() {
        return this.notificacoes
    }

    getUnreadCount() {
        return this.unreadCount
    }

    // Cleanup
    destroy() {
        if (this.channel) {
            supabase.removeChannel(this.channel)
        }
    }
}

// Instância singleton
export const notificacaoService = new NotificacaoService()

// Composable para usar no Vue
export function useNotificacoes() {
    const notificacoes = notificacaoService.getNotificacoesReativas()
    const unreadCount = notificacaoService.getUnreadCount()

    onMounted(async () => {
        await notificacaoService.getNotificacoes()
    })

    onUnmounted(() => {
        notificacaoService.destroy()
    })

    return {
        notificacoes,
        unreadCount,
        marcarComoLida: notificacaoService.marcarComoLida.bind(notificacaoService),
        marcarTodasComoLidas: notificacaoService.marcarTodasComoLidas.bind(notificacaoService),
        criarNotificacao: notificacaoService.criarNotificacao.bind(notificacaoService)
    }
}
